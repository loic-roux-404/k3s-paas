{
  config,
  lib,
  pkgs,
  ...
}: 

let dex_hostname = "${config.k3s-paas.dex.http_scheme}://dex.${config.k3s-paas.dns.name}";
in {
  imports = [ 
    "${builtins.toString ./.}/k3s-paas.nix"
  ];

  console = {
    earlySetup = true;
    keyMap = "fr";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  fileSystems."/".autoResize = true;
  boot.loader.systemd-boot.consoleMode = "max";

  system.stateVersion = "23.05";

  time = {
    timeZone = lib.mkForce "Europe/Paris";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  programs.ssh.package = pkgs.openssh_hpn;

  services = {
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

  services.fail2ban.enable = true;

  networking = {
    hostName = "k3s-paas";
    useNetworkd = true;
    useDHCP = false;
    firewall = {
      enable = true;
      allowedTCPPorts = lib.mkForce [80 443 22 6443];
    };
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${config.k3s-paas.user.name} = {
    xdg.enable = true;
    home.stateVersion = "23.05";
    home.file.".bashrc".source = lib.mkForce ./bashrc;
    home.file.".inputrc".source = ./inputrc;
    home.sessionVariables = {
      EDITOR = "vim";
      PAGER = "less -FirSwX";
    };
    programs.bash = {
      enable = true;
      historyControl = [ "ignoredups" "ignorespace" ];
      initExtra = "/home/${config.k3s-paas.user.name}/bashrc";
    };
  };

  environment = {
    shells = [ pkgs.bashInteractive ];
    systemPackages = with pkgs; [
      glibcLocales
      systemd
      coreutils
      gawk
      bashInteractive
      vim
      gitMinimal
      openssh_hpn
      btop
      curl
      dnsutils
      jq
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
