{
  description = "Nix Darwin configuration for my systems (from https://github.com/malob/nixpkgs)";

  inputs = {
    # Package sets
    nixpkgs-stable.url = "github:NixOS/nixpkgs/23.11";
    nixpkgs-stable-darwin.url = "github:NixOS/nixpkgs/nixpkgs-23.11-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    srvos.url = "github:numtide/srvos";

    # Environment/system management
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "srvos/nixpkgs";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "srvos/nixpkgs";
    };

    # Flake utilities
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs = { self, srvos, darwin, nixos-generators, flake-utils, ... }@inputs:
    let
      inherit (self.lib) attrValues makeOverridable mkForce optionalAttrs singleton;
      nixpkgsDefaults = {
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      lib = inputs.nixpkgs-unstable.lib.extend (_: _: {
        mkDarwinSystem = import ./lib/mkDarwinSystem.nix inputs;
      });

      overlays = {
        pkgs-stable = _: prev: {
          pkgs-stable = import inputs.nixpkgs-stable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        pkgs-unstable = _: prev: {
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit (prev.stdenv) system;
            inherit (nixpkgsDefaults) config;
          };
        };
        apple-silicon = _: prev: optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          # Add access to x86 packages system is running Apple Silicon
          pkgs-x86 = import inputs.nixpkgs-unstable {
            system = "x86_64-darwin";
            inherit (nixpkgsDefaults) config;
          };
        };

        tweaks = _: _: {
          # Add temporary overrides here
        };
      };

      darwinModules = {
        base = ./nixos/darwin.nix;
      };

      nixosModules = {
        server = srvos.nixosModules.server;
        configuration = ./nixos/configuration.nix;
      };

      darwinConfigurations = {
        # Minimal macOS configurations to bootstrap systems
        bootstrap-x86 = makeOverridable darwin.lib.darwinSystem {
          system = "x86_64-darwin";
          modules = [ ./nixos/darwin.nix { nixpkgs = nixpkgsDefaults; } ];
        };
        bootstrap-arm = self.darwinConfigurations.bootstrap-x86.override {
          system = "aarch64-darwin";
        };

        # My Apple Silicon macOS laptop config
        k3s-paas-host = makeOverridable self.lib.mkDarwinSystem ({
          modules = attrValues self.darwinModules ++ singleton {
            nixpkgs = nixpkgsDefaults;
            nix.registry.my.flake = inputs.self;
          };
          extraModules = singleton {};
        });

        # Config with small modifications needed/desired for CI with GitHub workflow
        githubCI = self.darwinConfigurations.k3s-paas-host.override {
          system = "x86_64-darwin";
          username = "runner";
          nixConfigDirectory = "/Users/runner/work/nixpkgs/nixpkgs";
          extraModules = singleton {
            environment.etc.shells.enable = mkForce false;
            environment.etc."nix/nix.conf".enable = mkForce false;
            homebrew.enable = mkForce false;
          };
        };
      };

      # NixOS ----------------------------------------------------------------------------------{{{
      nixosConfigurations = rec {
        default = qemu-aarch64-darwin;

        qcow-x86_64-linux = makeOverridable nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          modules = attrValues self.nixosModules ++ [
            ./nixos/qemu.nix
          ];
          format = "qcow";
        };

        qcow-aarch64 = self.nixosConfigurations.qcow-x86_64-linux.override {
          system = "aarch64-linux";
        };

        qemu-aarch64 = self.nixosConfigurations.qcow-aarch64.override {
          modules = attrValues self.nixosModules ++ [
            ./nixos/qemu.nix
          ];
          format = "vm-nogui";
        };

        qemu-aarch64-darwin = self.nixosConfigurations.qemu-aarch64.override {
          specialArgs = {
            vmPkgs = inputs.nixpkgs-stable.legacyPackages.aarch64-darwin;
          };
          modules = attrValues self.nixosModules ++ [
            ./nixos/aarch64-darwin-vm.nix
          ];
        };

        docker-x86_64-linux = makeOverridable nixos-generators.nixosGenerate {
          system =  "x86_64-linux";
          modules = attrValues self.nixosModules ++ [ 
            ./nixos/docker.nix
          ];
          format = "docker";
        };

        docker-arm = self.nixosConfigurations.docker-x86_64-linux.override {
          system = "aarch64-linux";
        };
      };
      # }}}

    } // flake-utils.lib.eachDefaultSystem (system: {
      # Re-export `nixpkgs-unstable` with overlays.
      # This is handy in combination with setting `nix.registry.my.flake = inputs.self`.
      # Allows doing things like `nix run my#prefmanager -- watch --all`
      legacyPackages = import inputs.nixpkgs-stable (nixpkgsDefaults // { inherit system; });

      # Development shells ----------------------------------------------------------------------{{{
      # Shell environments for development
      # With `nix.registry.my.flake = inputs.self`, development shells can be created by running,
      # e.g., `nix develop my#python`.
      devShells = let pkgs = self.legacyPackages.${system}; in
        {
          default = pkgs.mkShell {
            name = "default";
            packages = attrValues {
              inherit (pkgs) terraform docker-client kubectl nil coreutils e2fsprogs;
            };
            shellHook = (if pkgs.system == "aarch64-darwin" then ''
              nix build .#darwinConfigurations.k3s-paas-host.system
              ./result/sw/bin/darwin-rebuild switch --flake .#k3s-paas-host
            '' else "");
          };

          # python = pkgs.mkShell {
          #   name = "python310";
          #   inputsFrom = attrValues {
          #     inherit (pkgs.pkgs-master.python310Packages) black isort;
          #     inherit (pkgs) poetry python310 pyright;
          #   };
          # };
        };
      # }}}
    });
}
# vim: foldmethod=marker  