{ pkgs, ... }:
{
  default = import ./devShell.nix { inherit pkgs; };
}
