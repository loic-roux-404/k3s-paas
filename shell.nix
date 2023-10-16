{ system ? builtins.currentSystem }:
let
  d = import ./. { inherit system; src = ./devshell; };
in
d.devShells.${system}.default
