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
