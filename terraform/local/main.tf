module "qemu_instance" {
  source = "./qemu-nixos-vm"
  qemu_working_dir = "${path.module}/../.."
  vm_ip = var.vm_ip
  sudo_password = var.sudo_password
}

module "pebble" {
  source = "./pebble"
}
