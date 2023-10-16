{ modulesPath, lib, pkgs, ... }:
{
  imports = [
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  networking.interfaces.enp0s10.useDHCP = true;

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd = {
      availableKernelModules = lib.mkForce [ "xhci_pci" "uhci_hcd" "virtio_pci" "usbhid" "usb_storage" "sr_mod" ];
      kernelModules = [ ];
    };
    kernelModules = [ ];
    extraModulePackages = [ ];
    loader = {
      grub = {
        enable = lib.mkForce false;
        efiInstallAsRemovable = lib.mkForce false;
      };
      systemd-boot = {
        enable = true;
        consoleMode = "0";
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  services = {
    spice-vdagentd = {
      enable = true;
    };
  };

  environment = {
    variables = {
      LIBGL_ALWAYS_SOFTWARE = "1";
    };
  };

  swapDevices = [ ];
}
