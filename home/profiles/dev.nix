# Dev tools profile
{ pkgs, ... }:
{
  imports = [
    ../features/dev
  ];
  home.packages = with pkgs; [
    cursor-cli
  ];
}
