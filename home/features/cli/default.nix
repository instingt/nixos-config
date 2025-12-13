{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./ns.nix
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
