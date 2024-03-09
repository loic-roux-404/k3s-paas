terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  boot_spec = jsondecode(file("${path.cwd}/result/system/boot.json"))["org.nixos.bootspec.v1"]
  port_mappings = join(",", [for k, v in var.port_mappings : "hostfwd=tcp::${k}-:${v}"])
}

resource "libvirt_pool" "volumetmp" {
  name = "libvirt-pool-k3s-paas"
  type = "dir"
  path = "${path.cwd}/libvirt-nixos-pool"
}

resource "libvirt_volume" "base" {
  name   = "nixos"
  source = "${path.cwd}/k3s-paas.qcow2"
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

resource "libvirt_volume" "kernel" {
  name   = "nixos"
  source = local.boot_spec.kernel
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

resource "libvirt_volume" "vm-disk" {
  name           = "nixos.qcow2"
  base_volume_id = libvirt_volume.base.id
  pool           = libvirt_pool.volumetmp.name
  format         = "qcow2"
}

resource "libvirt_domain" "machine" {
  name     = "vm1"
  vcpu     = 2
  memory   = 4096
  type = "hvf"

  disk {
    volume_id = libvirt_volume.vm-disk.id
  }

  filesystem {
    source   = "/nix/store"
    target   = "nix-store"
    readonly = true
  }

  filesystem {
    source   = "${path.cwd}/xchg"
    target   = "xchg"
    readonly = false
  }

  filesystem {
    source   = "${path.cwd}/xchg"
    target   = "shared"
    readonly = false
  }

  graphics {
    type = "vnc"
    listen_type = "address"
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  initrd = local.boot_spec.initrd
  kernel = libvirt_volume.kernel.id

  cmdline = [{
    console = "ttyS0"
    console = "tty0"
    console = "ttyAMA0,115200"
    console = "ttyS0,115200"
    loglevel = 4
    "net.ifnames" = 0
    init = local.boot_spec.init
  }]

  xml {
    xslt = templatefile("${path.module}/nixos.xslt.tmpl", {
      commands = {
        "-netdev" = "user,id=user.0,${local.port_mappings}"
        "-nic" = "vmnet-bridged,ifname=${var.qemu_network_interface}"
      }
    })
  }
}

# output "ip-addresses" {
#   value = libvirt_domain.machine.network_interface.0.addresses.*
# }
