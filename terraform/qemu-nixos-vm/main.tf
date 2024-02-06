resource "null_resource" "start_qemu" {
  provisioner "local-exec" {
    environment = {
      QEMU_OPTS = "-daemonize"
      QEMU_NET_OPTS = "hostfwd=tcp::2222-:22,"
      OBJC_DISABLE_INITIALIZE_FORK_SAFETY = "YES"
    }
    working_dir = var.qemu_working_dir
    command = "./result/bin/run-k3s-paas-vm"
  }
}

resource "null_resource" "stop_qemu" {
  provisioner "local-exec" {
    command = "ps aux | grep qemu | grep run-k3s-paas-vm | grep -v grep | awk '{print $2}' | xargs kill || true"
    when = destroy
  }
}

locals {
  private_key = trimspace(file(pathexpand(var.ssh_connection.private_key)))
  interface_regexp = "inet [0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}"
}

resource "null_resource" "recover_ip" {

  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = var.ssh_connection.user
      host     = "localhost"
      private_key = local.private_key
    }

    inline = [ 
      "ip -o -4 a s | grep ${var.qemu_network_interface} | grep -E -o '${local.interface_regexp}' | cut -d' ' -f2"
    ]
  }
}

# resource "null_resource" "save_ip" {
#   triggers = {
#     always_run = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     command = "echo ${} > /tmp/ip-k3s-paas.txt"
#   }
# }

# TODO wait for the VM to be up and running
# find ip with an easy ssh command
output "ip" {
  value = null_resource.recover_ip
}
