{ pkgs, ... }:
{
  # GTK UI + mpv engine/CLI.
  home.packages = with pkgs; [
    celluloid
    mpv
  ];
}


