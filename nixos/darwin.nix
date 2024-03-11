{ pkgs, lib, config, ... }:
{
  imports = [ 
    "${builtins.toString ./.}/k3s-paas.nix"
  ];
  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };
  services.dnsmasq = {
    enable = true;
    addresses = {
      ".${config.k3s-paas.dns.name}" = config.k3s-paas.dns.dest-ip;
    };
  };
  launchd.daemons."libvirt" = {
    path = [ pkgs.gcc pkgs.qemu pkgs.dnsmasq pkgs.libvirt ];
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ProgramArguments = [ 
        "${pkgs.libvirt}/bin/libvirtd" "-f" "/etc/libvirt/libvirtd.conf" 
      ];
      StandardOutPath = "/var/log/libvirt.log";
      StandardErrorPath = "/var/log/libvirt.log";
    };
  };
  launchd.daemons."virtlogd" = {
    path = [ pkgs.libvirt ];
    serviceConfig = {
      KeepAlive = true;
      RunAtLoad = true;
      ProgramArguments = [ 
        "${pkgs.libvirt}/bin/virtlogd" 
      ];
      StandardOutPath = "/var/log/virtlogd.log";
      StandardErrorPath = "/var/log/virtlogd.log";
    };
  };
  networking = {
    knownNetworkServices = [
      "Wi-Fi"
      "Bluetooth PAN"
      "Thunderbolt Bridge"
    ];
  };
  environment.etc."libvirt/libvirtd.conf".text = ''
    mode = "direct"
    unix_sock_group = "staff"
    unix_sock_ro_perms = "0770"
    unix_sock_rw_perms = "0770"
    unix_sock_admin_perms = "0770"
    auth_unix_ro = "none"
    auth_unix_rw = "none"
  '';
  environment.etc."libvirt/qemu.conf".text = ''
    security_driver = "none"
    dynamic_ownership = 0
    remember_owner = 0
  '';
  environment.etc.${config.k3s-paas.dns.name}.text = "nameserver ${config.k3s-paas.dns.dest-ip}";
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
  nix.settings.experimental-features = "nix-command flakes";
}
