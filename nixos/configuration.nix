{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [ "${builtins.toString ./.}/k3s_paas.nix"];

  boot.loader.systemd-boot.consoleMode = "0";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.stateVersion = "23.11";

  time = {
    timeZone = lib.mkForce "Europe/Paris";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = lib.mkForce false;
        PermitRootLogin = "no";
      };
    };
    tailscale = {
      enable = true;
    };
    k3s = {
      enable = true;
      role = "server";
      extraFlags = toString [
        "--kube-apiserver-arg authorization-mode=Node,RBAC"
        "--kube-apiserver-arg oidc-issuer-url=${config.k3s_paas.dex.dex_hostname}"
        "--kube-apiserver-arg oidc-client-id=${config.k3s_paas.dex.dex_client_id}"
        "--kube-apiserver-arg oidc-username-claim=email"
        "--kube-apiserver-arg oidc-groups-claim=groups"
        "--disable=traefik"
      ];
    };
  };

  networking = {
    hostName = "k3s-paas";
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkForce [80 443 22 6443];
    };
  };

  environment = {
    systemPackages = lib.mkForce [
      pkgs.curl
      pkgs.gitMinimal
      pkgs.ipset
      pkgs.nftables
      pkgs.iptables
      pkgs.htop
      pkgs.wget
      pkgs.k3s
      pkgs.waypoint
      pkgs.tailscale
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  users = {
    allowNoPasswordLogin = true;
    users = {
      admin = {
        isNormalUser = true;
        extraGroups = [ "adm" "cdrom" "dip" "plugdev" "sudo"];
        openssh = {
          authorizedKeys = {
            keys = [
              config.k3s_paas.user.key
            ];
          };
        };
      };
    };
  };

  systemd = {
    services = {
      k3s = {
        path = [ pkgs.ipset ];
      };
    };
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };

  nix = {
    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };
}
