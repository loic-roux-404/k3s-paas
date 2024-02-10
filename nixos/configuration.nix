{
  config,
  lib,
  pkgs,
  ...
}: 

let dex_hostname = "${config.k3s-paas.dex.http_scheme}://dex.${config.k3s-paas.dns.name}";

in {
  imports = [ "${builtins.toString ./.}/k3s-paas.nix"];

  boot.kernelParams = [];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.growPartition = true;

  system.stateVersion = "23.11";

  time = {
    timeZone = lib.mkForce "Europe/Paris";
  };

  i18n.defaultLocale = "en_US.UTF-8";
  console.font = "Lat2-Terminus16";
  console.keyMap = "fr";

  programs.ssh.package = pkgs.openssh_hpn;

  services = {
    getty.autologinUser = config.k3s-paas.user.name;
    openssh = {
      enable = true;
      settings = {
        StreamLocalBindUnlink = "yes";
        # Allow forwarding ports to everywhere
        GatewayPorts = "clientspecified";
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
        "--kube-apiserver-arg oidc-issuer-url=${dex_hostname}"
        "--kube-apiserver-arg oidc-client-id=${config.k3s-paas.dex.dex_client_id}"
        "--kube-apiserver-arg oidc-username-claim=email"
        "--kube-apiserver-arg oidc-groups-claim=groups"
        "--disable=traefik"
      ];
    };
  };

  systemd.network.enable = true;
  networking.networkmanager.enable = true;
  networking.dhcpcd.enable = true;

  services.fail2ban.enable = true;

  networking = {
    hostName = "k3s-paas";
    usePredictableInterfaceNames = lib.mkForce true;
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkForce [80 443 22 6443];
    };
  };

  programs.bash.enableCompletion = true;

  environment = {
    enableAllTerminfo = true;
    shells = [ pkgs.bashInteractive pkgs.bash ];
    systemPackages = with pkgs; lib.mkForce [
      systemd
      bashInteractive
      bash
      coreutils
      ncurses
      iconv
      gawk
      vim
      gitMinimal
      openssh_hpn
      ipset
      iproute2
      nftables
      iptables
      btop
      curl
      wget
      k3s
      kubectl
      waypoint
      tailscale
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  security.pam.sshAgentAuth.enable = true;

  users = {
    defaultUserShell = pkgs.bashInteractive;
    allowNoPasswordLogin = true;
    users = {
      ${config.k3s-paas.user.name} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        openssh = {
          authorizedKeys = {
            keys = [
              config.k3s-paas.user.key
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
