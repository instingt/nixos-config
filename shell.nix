let
  pkgs = import <nixpkgs> { };
in
import ./devShell.nix { inherit pkgs; }
