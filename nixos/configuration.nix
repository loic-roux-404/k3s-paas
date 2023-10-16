{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [ "${builtins.toString ./.}/k3s_paas.nix"];

  system = {
    stateVersion = lib.version;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
  };

  time = {
    timeZone = lib.mkForce "Europe/Paris";
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = lib.mkForce true;
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
      pkgs.tmux
      pkgs.htop
      pkgs.wget
      pkgs.k3s
      pkgs.waypoint
      pkgs.tailscale
    ];
  };

  users = {
    mutableUsers = false;
    users = {
      root = {
        hashedPassword = lib.mkForce config.k3s_paas.root.password;
      };
      ${config.k3s_paas.user.name} = {
        isNormalUser = true;
        hashedPassword = config.k3s_paas.user.password;
        extraGroups = [ "adm" "cdrom" "dip" "plugdev" "sudo"];
        openssh = {
          authorizedKeys = {
            keys = [];
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
  };
}
