# We use the nixosConfigurations to test all the modules below.
#
# This is not optimal, but it gets the job done
{ k3s_paas, nixpkgs, system }:
let
  inherit (nixpkgs) lib;
  inherit (lib) nixosSystem;

  # some example configuration to make it eval
  dummy = { config, ... }: {
    networking.hostName = "example-common";
    system.stateVersion = config.system.nixos.version;
    users.users.root.initialPassword = "fnord23";
    boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];
    fileSystems."/".device = lib.mkDefault "/dev/sda";
  };
in
{
  example-vm = nixosSystem {
    inherit system;
    modules = [
      dummy
      k3s_paas.nixosModules.vm
    ];
  };
}