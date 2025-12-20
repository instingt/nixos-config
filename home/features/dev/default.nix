{ pkgs, ... }:
{
  imports = [
    ./cursor.nix
  ];
  home.packages = with pkgs; [
    cursor-cli
  ];
}
