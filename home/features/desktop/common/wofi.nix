_: {
  xdg.configFile."wofi/config".text = ''
    show=drun
    prompt=Run
    width=520
    lines=8
    allow_images=true
    image_size=24
    insensitive=true
    no_actions=true
    gtk_dark=true
  '';

  # Catppuccin Mocha-ish colors to match the rest of the desktop.
  xdg.configFile."wofi/style.css".text = ''
    * {
      font-family: Fira Sans, FiraMono Nerd Font;
      font-size: 12pt;
    }

    window {
      margin: 0px;
      border: 2px solid rgba(88, 91, 112, 0.8);
      border-radius: 12px;
      background-color: rgba(17, 17, 27, 0.94);
    }

    #input {
      margin: 12px;
      padding: 10px 12px;
      border: 2px solid rgba(49, 50, 68, 1.0);
      border-radius: 10px;
      background-color: rgba(30, 30, 46, 0.85);
      color: rgba(205, 214, 244, 1.0);
    }

    #inner-box {
      margin: 0 12px 12px 12px;
      border: none;
      background-color: transparent;
    }

    #entry {
      padding: 8px 10px;
      border-radius: 10px;
      color: rgba(205, 214, 244, 0.90);
    }

    #entry:selected {
      background-color: rgba(49, 50, 68, 0.9);
      color: rgba(205, 214, 244, 1.0);
    }

    #text {
      margin: 0 10px;
    }
  '';
}
