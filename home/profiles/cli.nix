# CLI tools profile
{ pkgs, ... }:
{
  imports = [
    ../features/cli/fish.nix
    ../features/cli/git.nix
    ../features/cli/ns.nix
    ../features/cli/gpg.nix
  ];
  home.packages = with pkgs; [
    bc
    bottom
    ncdu
    eza
    ripgrep
    fd
    httpie
    jq
  ];
}
