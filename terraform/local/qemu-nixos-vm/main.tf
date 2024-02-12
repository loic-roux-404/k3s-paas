resource "null_resource" "start_qemu" {
  provisioner "local-exec" {
    environment = {
      QEMU_OPTS = "-daemonize -nic vmnet-bridged,ifname=${var.qemu_network_interface}"
      QEMU_NET_OPTS = join(",", [for k, v in var.port_mappings : "hostfwd=tcp::${k}-:${v},"])
      OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES"
    }
    working_dir = var.qemu_working_dir
    command = "echo ${var.sudo_password} || sudo -S ./result/bin/run-k3s-paas-vm"
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

resource "null_resource" "vm_started" {
  provisioner "remote-exec" {
    connection {
      type     = "ssh"
      user     = var.ssh_connection.user
      host     = "localhost"
      private_key = local.private_key
      port = "2222"
      agent = false
      timeout = "45s"
    }

    inline = [ "echo 'Machine Started'" ]
  }
}

data "external" "ip" {
  depends_on = [ null_resource.vm_started ]
  program = ["bash", "./${path.module}/info-scripts/ip.sh"]
  query = {
    ssh_connection_user = var.ssh_connection.user
    ssh_connection_private_key = var.ssh_connection.private_key
  }
}

data "external" "host_ip" {
  program = ["bash", "./${path.module}/info-scripts/host_ip.sh"]
}

output "ip" {
  depends_on = [ data.external.ip ]
  value = data.external.ip.result.result
}

output "host_ip" {
  depends_on = [ null_resource.vm_started ]
  value = data.external.host_ip.result.result
}
