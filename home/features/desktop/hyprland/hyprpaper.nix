{
  config,
  lib,
  pkgs,
  ...
}:
let
  wallpaperPath = if config.wallpaper == null then null else builtins.toString config.wallpaper;
in
{
  home.packages = [ pkgs.hyprpaper ];

  xdg.configFile."hypr/hyprpaper.conf" = lib.mkIf (wallpaperPath != null) {
    text = ''
      preload = ${wallpaperPath}
      wallpaper = ,${wallpaperPath}
    '';
  };
}
