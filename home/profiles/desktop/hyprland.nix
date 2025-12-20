# Hyprland desktop profile
{ pkgs, ... }:
{
  imports = [
    ../../features/desktop/hyprland
  ];

  # Catppuccin wallpaper (landscapes/forrest.png)
  # This can be overridden per-user if needed
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/forrest.png";
    hash = "sha256-jDqDj56e9KI/xgEIcESkpnpJUBo6zJiAq1AkDQwcHQM=";
  };

  # Hyprland-specific xdg.portal configuration
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "hyprland";
  };
}
