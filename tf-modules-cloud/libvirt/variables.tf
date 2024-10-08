variable "mac" {
  type = string
  default = "de:ad:be:ef:0:1"
}

variable "vm_size" {
  description = "vm size in MB"
  default     = "16G"
}

variable "darwin" {
  type    = bool
  default = true
}

variable "ssh_connection" {
  description = "values for the ssh connection"
  type = object({
    private_key = string
    user        = string
  })
  default = {
    private_key = "~/.ssh/id_ed25519"
    user        = "admin"
  }
}

variable "libvirt_pool_path" {
  default = "/var/lib/libvirt-pools/kube-paas-pool"
}

variable "node_hostname" {
  type    = string
  default = "localhost-0"
}

variable "arch" {
  type = string
  default = "x86_64"
}

variable "libvirt_qcow_source" {
  default = "result/nixos.qcow2"
}
