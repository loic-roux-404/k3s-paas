{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    srvos.url = "github:numtide/srvos";
    nixpkgs.follows = "srvos/nixpkgs";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "srvos/nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, srvos, ... }: {
    lib.supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    lib.devShellSystems = self.lib.supportedSystems ++ [
      "aarch64-darwin"
    ];

    packages = nixpkgs.lib.genAttrs self.lib.supportedSystems (system: {
      qcow = nixos-generators.nixosGenerate {
        inherit system;
        modules = [ 
          #srvos.nixosModules.server
          ./nixos/qemu.nix
          ./nixos/configuration.nix
        ];
        format = "qcow";
      };

      docker = nixos-generators.nixosGenerate {
        inherit system;
        modules = [ 
          srvos.nixosModules.server
          ./nixos/docker.nix
          ./nixos/configuration.nix
        ];
        format = "docker";
      };
    });
  };
}
