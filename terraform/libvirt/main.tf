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
  kernel_params = flatten([
    for obj in local.boot_spec.kernelParams : {
      split("=", obj)[0] = split("=", obj)[1]
    }
  ])
}

resource "libvirt_pool" "volumetmp" {
  name = "libvirt-pool-k3s-paas"
  type = "dir"
  path = "${path.cwd}/libvirt-nixos-pool"
}

resource "libvirt_volume" "base" {
  name   = "k3s-paas.qcow2"
  source = "${path.cwd}/k3s-paas.qcow2"
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

resource "libvirt_volume" "kernel" {
  name   = "kernel"
  source = local.boot_spec.kernel
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

resource "libvirt_volume" "vm-disk" {
  name           = "storage.qcow2"
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
    volume_id = libvirt_volume.base.id
  }

  disk {
    volume_id = libvirt_volume.vm-disk.id
  }

  filesystem {
    source   = "/nix/store"
    target   = "/nix/store"
    readonly = true
  }

  filesystem {
    source   = "${path.cwd}/xchg"
    target   = "/xchg"
    readonly = false
  }

  filesystem {
    source   = "${path.cwd}/xchg"
    target   = "/shared"
    readonly = false
  }

  # graphics {
  #   type = "vnc"
  #   listen_type = "address"
  #   autoport = true
  # }

  # console {
  #   type        = "pty"
  #   target_port = "0"
  #   target_type = "virtio"
  #   source_path = "/dev/pts/4"
  # }

  # video {
  #   type = "virtio"
  # }

  initrd = local.boot_spec.initrd
  kernel = libvirt_volume.kernel.id
  cmdline = concat(
    local.kernel_params,
    [{ init = local.boot_spec.init }]
  )

  xml {
    xslt = templatefile("${path.module}/nixos.xslt.tmpl", {
      args = [
        "-netdev", "user,id=user.0,${local.port_mappings}",
        "-net", "nic,netdev=user.0,model=virtio,addr=0x8",
        "-netdev", "vmnet-bridged,id=bridge.0,ifname=${var.qemu_network_interface}",
        "-device", "virtio-net-pci,netdev=bridge.0,addr=0x9",
        "-nographic", "-serial", "mon:stdio"
      ]
    })
  }
}

# output "ip-addresses" {
#   value = libvirt_domain.machine.network_interface.0.addresses.*
# }
