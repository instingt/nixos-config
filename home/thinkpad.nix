{ pkgs, ... }:
{
  imports = [
    ./global

    ./features/desktop/hyprland
  ];

  # Catppuccin wallpaper (landscapes/forrest.png)
  wallpaper = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/zhichaoh/catppuccin-wallpapers/main/landscapes/forrest.png";
    hash = "sha256-jDqDj56e9KI/xgEIcESkpnpJUBo6zJiAq1AkDQwcHQM=";
  };
}
