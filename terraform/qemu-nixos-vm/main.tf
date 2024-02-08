resource "null_resource" "start_qemu" {
  provisioner "local-exec" {
    environment = {
      QEMU_OPTS = "-daemonize"
      QEMU_NET_OPTS = "hostfwd=tcp::2222-:22,"
      OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES"
      QEMU_KERNEL_PARAMS = "console=ttyS0"
    }
    working_dir = var.qemu_working_dir
    command = "./result/bin/run-k3s-paas-vm"
  }
}

resource "null_resource" "stop_qemu" {
  provisioner "local-exec" {
    command = "ps aux | grep qemu | grep nixos-system-k3s-paas | grep -v grep | awk '{print $2}' | xargs kill"
    when = destroy
  }
}

locals {
  private_key = trimspace(file(pathexpand(var.ssh_connection.private_key)))
}

resource "null_resource" "recover_ip" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.ssh_connection.user
      host     = "localhost"
      private_key = local.private_key
      port = "2222"
      agent = false
    }

    inline = [ "echo 'Machine Started'" ]
  }
}

data "external" "ip" {
  depends_on = [ null_resource.recover_ip ]
  program = ["bash", "${path.module}/info-scripts/ip.sh"]
  query = {
    ssh_connection_user = var.ssh_connection.user
    ssh_connection_private_key = var.ssh_connection.private_key
  }
}

data "external" "host_ip" {
  program = ["bash", "${path.module}/info-scripts/host_ip.sh"]
}

output "ip" {
  depends_on = [ data.external.ip ]
  value = data.external.ip.result
}

output "host_ip" {
  value = data.external.host_ip.result
}