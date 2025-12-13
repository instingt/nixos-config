{ pkgs, ... }:
{
  home.packages = [ pkgs.kitty ];
  programs.kitty = {
    enable = true;
    themeFile = "tokyo_night_night";
    settings = {
      confirm_os_window_close = 0;
    };
  };
}
