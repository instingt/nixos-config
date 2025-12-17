_: {
  # Minimal Catppuccin-ish styling for SwayOSD.
  xdg.configFile."swayosd/style.css".text = ''
    window {
      background: rgba(17, 17, 27, 0.90);
      border-radius: 14px;
      border: 2px solid rgba(88, 91, 112, 0.80);
      padding: 12px 14px;
    }

    label {
      color: rgba(205, 214, 244, 1.0);
      font-family: Fira Sans;
      font-size: 14px;
    }

    progressbar {
      min-height: 10px;
      border-radius: 999px;
      background: rgba(49, 50, 68, 1.0);
    }

    progressbar > trough > progress {
      border-radius: 999px;
      background: rgba(137, 180, 250, 1.0);
    }
  '';
}
