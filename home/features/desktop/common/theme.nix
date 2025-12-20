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
  home = {
    packages = [
      gtkThemePkg
      cursorPkg
    ];

    pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = cursorPkg;
      name = cursorName;
      size = cursorSize;
    };

    sessionVariables = {
      GTK_THEME = gtkThemeName;
    };
  };

  # Ensure terminal TUIs (notably `nmtui`, which uses newt) have readable colors.
  # This is picked up by systemd-managed Waybar and other user services.
  systemd.user.sessionVariables = {
    COLORTERM = "truecolor";
    # newt prefers a semicolon-separated string; this is more reliable than newlines
    # when passed through systemd environments.
    NEWT_COLORS =
      # Catppuccin-ish: keep background dark, avoid the very bright cyan accents.
      # Notes: newt only supports a small named color set; this maps onto the terminal palette.
      "root=lightgray,black;window=lightgray,black;border=darkgray,black;shadow=black,black;title=lightgray,black;"
      + "button=lightgray,black;actbutton=black,blue;checkbox=lightgray,black;actcheckbox=black,blue;"
      + "entry=lightgray,black;label=lightgray,black;listbox=lightgray,black;actlistbox=black,blue;"
      + "textbox=lightgray,black;acttextbox=black,blue;helpline=darkgray,black;roottext=darkgray,black;"
      + "emptyscale=darkgray,black;fullscale=blue,black;disentry=darkgray,black";
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
}
