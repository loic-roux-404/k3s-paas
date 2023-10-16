{ prefix, k3s_paas, nixpkgs, system }:
let
  pkgs = nixpkgs.legacyPackages.${system};

  inherit (nixpkgs) lib;

  nixosTest = import "${pkgs.path}/nixos/lib/testing-python.nix" {
    inherit pkgs;
    system = pkgs.system;
  };

  moduleTests = {
    server = nixosTest.makeTest {
      name = "${prefix}-server";

      nodes.machine = { ... }: {
        imports = [ k3s_paas.nixosModules.server ];
        networking.hostName = "machine";
      };
      testScript = ''
        machine.wait_for_unit("sshd.service")
        # TODO: kubernetes availability over port 6443
      '';
    };
  };

  configurations = import ./test-configurations.nix {
    inherit k3s_paas nixpkgs system;
  };

  # Add all the nixos configurations to the checks
  nixosChecks =
    lib.mapAttrs'
      (name: value: { name = "${prefix}-${name}"; value = value.config.system.build.toplevel; })
      configurations;
in
nixosChecks // moduleTests