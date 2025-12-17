{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../common
    ./waybar.nix
    ./mako.nix
    ./hyprpaper.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./wlogout.nix
    ./swayosd.nix
  ];
  home.packages =
    let
      screenshotScript = builtins.readFile ./scripts/screenshot.sh;
      clipboardScript = builtins.readFile ./scripts/clipboard.sh;
    in
    with pkgs;
    [
      # Needed for auth prompts (NetworkManager, mounts, etc.) under Hyprland.
      polkit_gnome
      wofi
      wl-clipboard
      cliphist
      grim
      slurp
      swappy
      swayosd
      playerctl
      brightnessctl
      pamixer
      (writeShellScriptBin "hypr-screenshot" screenshotScript)
      (writeShellScriptBin "hypr-clipboard" clipboardScript)
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
        "MOZ_ENABLE_WAYLAND,1"
        "GTK_THEME,catppuccin-mocha-blue-standard"
        "QT_QPA_PLATFORMTHEME,gtk2"
        "QT_STYLE_OVERRIDE,gtk2"
        "XCURSOR_THEME,catppuccin-mocha-blue-cursors"
        "XCURSOR_SIZE,20"
        "HYPRCURSOR_THEME,catppuccin-mocha-blue-cursors"
        "HYPRCURSOR_SIZE,20"
      ];

      monitor =
        let
          monitorLine =
            m:
            if !(m.enabled or true) then
              "${m.name},disable"
            else
              let
                res = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
                pos = if m.position == "auto" then "auto" else m.position;
                scale = lib.strings.floatToString m.scale;
              in
              "${m.name},${res},${pos},${scale}";
        in
        if config.monitors != [ ] then (map monitorLine config.monitors) else [ ",preferred,auto,1.5" ];

      "exec-once" = [
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
        "mako"
        "hypridle"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ]
      ++ lib.optionals (config.wallpaper != null) [ "hyprpaper" ];

      bind = [
        "$mod,RETURN,exec,kitty"
        "$mod,R,exec,wofi --show drun"

        "$mod,Q,killactive"
        "$mod,F,fullscreen"
        "$mod SHIFT,Q,exec,hyprctl dispatch exit"
        "$mod SHIFT,R,exec,hyprctl reload"

        "$mod,H,movefocus,l"
        "$mod,L,movefocus,r"
        "$mod,J,movefocus,d"
        "$mod,K,movefocus,u"

        "$mod,SPACE,togglefloating"
        "$mod,ESCAPE,exec,wlogout"
        "$mod SHIFT,X,exec,wlogout"
        "$mod SHIFT,L,exec,hyprlock"

        ",Print,exec,hypr-screenshot full"
        "SHIFT,Print,exec,hypr-screenshot region"
        "CTRL,Print,exec,hypr-screenshot full-edit"
        "CTRL SHIFT,Print,exec,hypr-screenshot region-edit"

        "$mod,V,exec,hypr-clipboard"
      ]
      ++ (builtins.concatLists (
        builtins.genList (
          i:
          let
            ws = toString (i + 1);
          in
          [
            "$mod,${ws},workspace,${ws}"
            "$mod SHIFT,${ws},movetoworkspace,${ws}"
          ]
        ) 9
      ));

      bindm = [
        "$mod,mouse:272,movewindow"
        "$mod,mouse:273,resizewindow"
      ];

      bindl = [
        ",XF86AudioMute,exec,sh -lc 'swayosd-client --output-volume mute-toggle || pamixer -t'"
        ",XF86AudioMicMute,exec,sh -lc 'swayosd-client --input-volume mute-toggle || pamixer --default-source -t'"
        ",XF86AudioPlay,exec,playerctl play-pause"
        ",XF86AudioNext,exec,playerctl next"
        ",XF86AudioPrev,exec,playerctl previous"
      ];

      bindle = [
        ",XF86AudioRaiseVolume,exec,sh -lc 'swayosd-client --output-volume raise 5 || pamixer -i 5'"
        ",XF86AudioLowerVolume,exec,sh -lc 'swayosd-client --output-volume lower 5 || pamixer -d 5'"
        ",XF86MonBrightnessUp,exec,sh -lc 'swayosd-client --brightness raise 5 || brightnessctl set +5%'"
        ",XF86MonBrightnessDown,exec,sh -lc 'swayosd-client --brightness lower 5 || brightnessctl set 5%-'"
      ];

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        # Reduce scroll speed a bit on touchpads (1.0 is default).
        scroll_factor = 0.8;

        touchpad = {
          natural_scroll = true;
          clickfinger_behavior = true;
          "tap-to-click" = false;
          "tap-and-drag" = false;
          drag_lock = false;
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
        blur.enabled = false;
      };

      animations = {
        enabled = false;
      };
    };

  };

  # Run swayosd as a proper user service (prevents duplicate instances and keeps it alive).
  systemd.user.services.swayosd-server = {
    Unit = {
      Description = "SwayOSD server";
      PartOf = [
        "hyprland-session.target"
        "graphical-session.target"
      ];
      After = [
        "hyprland-session.target"
        "graphical-session.target"
      ];
    };
    Service = {
      ExecStart = "${pkgs.swayosd}/bin/swayosd-server --style %h/.config/swayosd/style.css";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install = {
      WantedBy = [
        "hyprland-session.target"
        "graphical-session.target"
      ];
    };
  };
}
