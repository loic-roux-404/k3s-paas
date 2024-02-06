variable "qemu_working_dir" {}

variable "qemu_network_interface" {
  default = "eth0"
}

variable "ssh_connection" {
  description = "values for the ssh connection"
  type        = object({
    private_key = string
    user        = string
  })
  default = {
    private_key = "~/.ssh/id_ed25519"
    user = "admin"
  }
}