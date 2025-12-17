{ pkgs, ... }:
let
  gtkThemePkg = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [ "blue" ];
    size = "standard";
    tweaks = [ ];
  };
  gtkThemeName = "catppuccin-mocha-blue-standard";

  cursorPkg = pkgs.catppuccin-cursors.mochaBlue;
  cursorName = "catppuccin-mocha-blue-cursors";
  cursorSize = 20;
in
{
  home.packages = [
    gtkThemePkg
    cursorPkg
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = cursorPkg;
    name = cursorName;
    size = cursorSize;
  };

  gtk = {
    enable = true;
    theme = {
      package = gtkThemePkg;
      name = gtkThemeName;
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    cursorTheme = {
      package = cursorPkg;
      name = cursorName;
      size = cursorSize;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "gtk2";
  };

  home.sessionVariables = {
    GTK_THEME = gtkThemeName;
  };
}
