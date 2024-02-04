{ lib, ... }:

{
  options.k3s_paas = {

    user.name = lib.mkOption {
      default = "zizou";
      type = lib.types.str;
      description = "Nom d'utilisateur pour k3s_paas.";
    };

    user.key = lib.mkOption {
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC94/4uRn429xMGLFWZMyJWlhb5D0L3EoO8HxzN4q1ps loic@Windows-8-Phone.local";
      type = lib.types.str;
      description = "SSH public key pour k3s_paas.";
    };

    dex.dex_hostname = lib.mkOption {
      default = "https://dex.k3s.test";
      type = lib.types.str;
      description = "Nom d'hôte pour Dex dans k3s_paas.";
    };

    dex.dex_client_id = lib.mkOption {
      default = "client-id";
      type = lib.types.str;
      description = "Client ID pour Dex dans k3s_paas.";
    };
  };
}
