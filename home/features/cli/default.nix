{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./ns.nix
    ./gpg.nix
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
