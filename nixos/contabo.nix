{ lib, ... }:
{
  # boot.loader.grub = {
  #   efiSupport = true;
  #   efiInstallAsRemovable = true;
  #   device = "nodev";
  # };

  boot.initrd.kernelModules = lib.mkForce ["dm-snapshot"];

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
}
