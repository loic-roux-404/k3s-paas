{ lib, ... }:

{
  options.k3s-paas = {

    dns.name = lib.mkOption {
      default = "k3s.test";
      type = lib.types.str;
      description = "hostname for k3s-paas";
    };

    dns.dest-ip = lib.mkOption {
      default = "127.0.0.1";
      type = lib.types.str;
      description = "Targey IP address for dns.name";
    };

    user.name = lib.mkOption {
      default = "zizou";
      type = lib.types.str;
      description = "User name";
    };

    user.key = lib.mkOption {
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC94/4uRn429xMGLFWZMyJWlhb5D0L3EoO8HxzN4q1ps loic@Windows-8-Phone.local";
      type = lib.types.str;
      description = "SSH public key for k3s-paas.";
    };

    dex.http_scheme = lib.mkOption {
      default = "https";
      type = lib.types.str;
      description = "Http protocol for Dex in k3s-paas.";
    };

    dex.dex_client_id = lib.mkOption {
      default = "client-id";
      type = lib.types.str;
      description = "Client ID for Dex";
    };
  };
}
