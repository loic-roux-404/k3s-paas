{ lib, ... }:

{
  options.k3s_paas = {
    root.password = lib.mkOption {
      default = "$6$zizou$reVO3q7LFsUq.GT5P5pYFFcpxCo7eTRT5yJTD.gVoOy/FSzHEtXdofvZ7E04Rej.jiQHKaWJB0Qob5FHov1WU/";
      type = lib.types.str;
      description = "Root password";
    };

    user.name = lib.mkOption {
      default = "admin";
      type = lib.types.str;
      description = "Nom d'utilisateur pour k3s_paas.";
    };

    user.password = lib.mkOption {
      default = "$6$zizou$reVO3q7LFsUq.GT5P5pYFFcpxCo7eTRT5yJTD.gVoOy/FSzHEtXdofvZ7E04Rej.jiQHKaWJB0Qob5FHov1WU/";
      type = lib.types.str;
      description = "Mot de passe de l'utilisateur pour k3s_paas.";
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
