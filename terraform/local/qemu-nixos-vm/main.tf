resource "null_resource" "start_qemu" {

  provisioner "local-exec" {
    environment = {
      QEMU_OPTS = "-daemonize -nic vmnet-bridged,ifname=${var.qemu_network_interface}"
      QEMU_NET_OPTS = join(",", [for k, v in var.port_mappings : "hostfwd=tcp::${k}-:${v}"])
      OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES"
    }
    working_dir = var.qemu_working_dir
    command = "echo ${var.sudo_password} | sudo -SE ./result/bin/run-k3s-paas-vm"
  }
}

resource "null_resource" "destroy_qemu" {
  triggers = {
    sudo_password = var.sudo_password
  }
  provisioner "local-exec" {
    command = <<EOF
      pid=$(ps aux | grep qemu | grep nixos-system-k3s-paas | grep -v grep | awk '{print $2}') &&
      if [ -n "$pid" ]; then
        echo ${self.triggers.sudo_password} | sudo kill $pid
      fi
    EOF
    when = destroy
  }
}

resource "null_resource" "destroy_disk" {
  triggers = {
    qemu_working_dir = var.qemu_working_dir
  }
  provisioner "local-exec" {
    working_dir = self.triggers.qemu_working_dir
    command = <<EOF
      rm -rf k3s-paas.qcow2
    EOF
    when = destroy
  }
}

locals {
  private_key = trimspace(file(pathexpand(var.ssh_connection.private_key)))
}

resource "null_resource" "vm_started" {
  depends_on = [ null_resource.start_qemu ]
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

output "ip" {
  depends_on = [ data.external.ip ]
  value = data.external.ip.result.result
}
