terraform {
  required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  port_mappings = join(",", [for k, v in var.port_mappings : "hostfwd=tcp::${k}-:${v}"])
  debug_cmdline = var.debug ? ["-serial", "mon:stdio"] : []
  darwin_cmdline = var.darwin ? [
    "-netdev", "vmnet-bridged,id=bridge.0,ifname=${var.qemu_network_interface}",
    "-device", "virtio-net-pci,netdev=bridge.0,addr=0x9"
  ] : []
}

resource "libvirt_pool" "volumetmp" {
  name = "libvirt-pool-k3s-paas"
  type = "dir"
  path = "${path.cwd}/libvirt-nixos-pool"
}

resource "libvirt_volume" "nixos" {
  name   = "nixos.qcow2"
  source = "${path.cwd}/result/nixos.qcow2"
  pool   = libvirt_pool.volumetmp.name
  format = "qcow2"
}

resource "libvirt_domain" "machine" {
  name   = "vm1"
  vcpu   = 2
  memory = 4096
  type   = "hvf"
  autostart = true

  disk {
    volume_id = libvirt_volume.nixos.id
  }

  filesystem {
    source   = "/nix/store"
    target   = "nix-store"
    readonly = false
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

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  video {
    type = "vga"
  }

  cpu {
    mode = "host-passthrough"
  }

  initrd = local.boot_spec.initrd
  kernel = libvirt_volume.kernel.id
  cmdline = concat(
    local.kernel_params,
    [{ init = local.boot_spec.init }]
  )


  xml {
    xslt = templatefile("${path.module}/nixos.xslt.tmpl", {
      args = concat([
        "-netdev", "user,id=user.0,${local.port_mappings}",
        "-net", "nic,netdev=user.0,model=virtio,addr=0x8",
        ],
        local.darwin_cmdline,
        local.debug_cmdline
      )
    })
  }
}

# output "ip-addresses" {
#   value = libvirt_domain.machine.network_interface.0.addresses.*
# }
