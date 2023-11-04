{ lib, ... }:

{
  options.k3s_paas = {

    user.name = lib.mkOption {
      default = "zizou";
      type = lib.types.str;
      description = "Nom d'utilisateur pour k3s_paas.";
    };

    user.key = lib.mkOption {
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJnlabjQuAAy22LB5VZe2fwIMX3h8p+azwncd8bKwS0B zizou";
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
