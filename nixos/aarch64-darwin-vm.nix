{ vmPkgs, ... }:
{
  virtualisation.vmVariant.virtualisation = {
    host.pkgs = vmPkgs;
    useHostCerts = true;
    forwardPorts = [
      { from = "host"; host.port = 2222; guest.port = 22; }
    ];
  };
}
