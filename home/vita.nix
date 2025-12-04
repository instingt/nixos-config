{ config, pkgs, ... }:

{
  home.username = "vita";
  home.homeDirectory = "/home/vita";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    fd
    ripgrep
    tmux
  ];

  programs.git = {
    enable = true;
    userName = "Vitalii Kataev";
    userEmail = "vita@kataev.pro";
  };
}
