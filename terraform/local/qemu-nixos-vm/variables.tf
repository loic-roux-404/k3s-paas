variable "qemu_working_dir" {}

variable "qemu_network_interface" {
  default = "en0"
}

variable "port_mappings" {
  type = map(number)
  default = {
    2222 = 22
    6443 = 6443
    443  = 443
    80   = 80
  }
}

variable "ssh_connection" {
  description = "values for the ssh connection"
  type        = object({
    private_key = string
    user        = string
  })
  default = {
    private_key = "~/.ssh/id_ed25519"
    user = "zizou"
  }
}

variable "vm_ip_gateway" {
  default = "192.168.31.1"
}

variable "vm_ip" {
  default = "192.168.31.69"
}

variable "sudo_password" {
  default = "zizou"
  #sensitive = true
}
