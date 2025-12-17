{ pkgs, ... }:
{
  home.packages = [ pkgs.kitty ];
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    settings = {
      confirm_os_window_close = 0;
    };
  };
}
