{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/installer/scan/not-detected.nix"
  ];

  boot.initrd.availableKernelModules = [ "uhci_hcd" "ahci" "xhci_pci" "nvme" "usbhid" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

  swapDevices = [ ];

  networking.interfaces.en0 = {
    useDHCP = false;
    ipv4.addresses = [
      { address = "192.168.31.69";
        prefixLength = 24;
      }
    ];
  };
  networking.defaultGateway = {
    address = "192.168.31.1";
    interface = "en0";
  };
}
