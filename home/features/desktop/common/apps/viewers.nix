{ pkgs, ... }:
{
  # Simple GTK viewers that follow the configured GTK theme.
  home.packages = with pkgs; [
    evince
    eog
  ];
}


