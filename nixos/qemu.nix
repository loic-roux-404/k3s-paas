{ pkgs, modulesPath, config, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ahci" "xhci_pci" "nvme" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  swapDevices = [ ];

  virtualisation.host.pkgs = pkgs;
  virtualisation.vlans = [ 1 ];

  services.getty.autologinUser = config.k3s-paas.user.name;
}
