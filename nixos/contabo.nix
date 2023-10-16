{ lib, ... }:
{
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

  # May be needed for some systems
  # boot.loader.systemd-boot.enable = lib.mkForce false;
  # boot.loader.grub.enable = true;
}