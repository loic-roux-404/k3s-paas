locals {
  libvirt_root = "${abspath(pathexpand("~"))}/.cache"
}

provider "libvirt" {
  uri = "qemu:///session?root=${local.libvirt_root}&socket=${local.libvirt_root}/libvirt/libvirt-sock"
}

resource "libvirt_pool" "default" {
  name = "default"
  type = "dir"
  path = "${abspath(pathexpand("~"))}/.cache/libvirt/images"
}

resource "libvirt_volume" "qcow2_disk" {
  name   = "test_disk.qcow2"
  pool   = libvirt_pool.default.name
  source = var.qcow2_image_path
  format = "qcow2"
}

resource "libvirt_domain" "domain-qcow2-test" {
  name   = "test-vm"
  memory = "1024"
  vcpu   = 1

  disk {
    volume_id = libvirt_volume.qcow2_disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }

  # graphics {
  #   type        = "spice"
  #   listen_type = "address"
  #   autoport    = true
  # }

  xml {
    xslt = file("${path.module}/only-qemu.xsl")
  }
}
