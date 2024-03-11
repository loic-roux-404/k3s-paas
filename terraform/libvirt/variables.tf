variable "port_mappings" {
  type = map(number)
  default = {
    2222 = 22
    6443 = 6443
    443  = 443
    80   = 80
    5900 = 5900
  }
}

variable "qemu_network_interface" {
  default = "en0"
}
