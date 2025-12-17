{ pkgs, ... }:

{
  imports = [ ../common ];
  home.packages = with pkgs; [
    wofi
    wl-clipboard
  ];
  home.exportedSessionPackages = [
    pkgs.hyprland-session-quiet
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd = {
      enable = true;
      variables = [ "--all" ];
    };

    settings = {
      "$mod" = "SUPER";

      # Wayland session only: make Electron/Chromium apps prefer native Wayland.
      env = [
        "NIXOS_OZONE_WL,1"
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
      ];

      monitor = [
        ",preferred,auto,1.5"
      ];

      bind = [
        "$mod,RETURN,exec,kitty"
        "$mod,R,exec,wofi --show drun"

        "$mod,Q,killactive"
        "$mod,F,fullscreen"

        "$mod,H,movefocus,l"
        "$mod,L,movefocus,r"
        "$mod,J,movefocus,d"
        "$mod,K,movefocus,u"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;

        touchpad = {
          natural_scroll = true;
        };
      };

      general = {
        gaps_in = 0;
        gaps_out = 0;
        border_size = 0;
      };

      decoration = {
        rounding = 0;
        shadow.enabled = false;
      };

      animations = {
        enabled = true;
      };
    };

  };
}
