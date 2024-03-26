variable "port_mappings" {
  type = map(number)
  default = {
    2222 = 22
    6443 = 6443
    443  = 443
    80   = 80
  }
}

variable "qemu_network_interface" {
  default = "en0"
}

variable "vm_size" {
  description = "vm size in MB"
  default = 8092
}

variable "debug" {
  type = bool
  default = false
}

variable "darwin" {
  type = bool
  default = true
}
