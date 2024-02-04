{ pkgs, lib, ... }:
{
  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };
  nix.settings = {
    trusted-users = [ "staff" "admin" "nixbld"];
    keep-derivations = false;
    keep-outputs = false;
    # https://github.com/NixOS/nix/issues/7273
    auto-optimise-store = false;
  };
  nix.linux-builder.enable = true;
  nix.linux-builder.maxJobs = 8;
  nix.linux-builder.ephemeral = true;
  nix.linux-builder.config = ({ pkgs, ... }:
    {
      virtualisation.diskSize = lib.mkForce (16 * 1024);
    }
  );
  nix.configureBuildUsers = true;
  nix.distributedBuilds = true;
  services.nix-daemon.enable = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}