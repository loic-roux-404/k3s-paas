module "qemu_instance" {
  source = "./qemu-nixos-vm"
  qemu_working_dir = "${path.module}/../.."
  sudo_password = var.sudo_password
}

module "pebble" {
  source = "./pebble"
}

output "ip" {
  value = module.qemu_instance.ip
}
