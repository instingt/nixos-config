{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../common/wofi.nix
    ./waybar.nix
    ./mako.nix
    ./battery-notify.nix
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
      networkmanager
      pavucontrol
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
        "COLORTERM,truecolor"
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
        if config.monitors != [ ] then (map monitorLine config.monitors) else [ ",preferred,auto,1.25" ];

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
        # Add spacing between buttons (wlogout uses these flags for grid spacing).
        # -s/--show-binds renders keybind tips as `Action[key]`
        # Force layout+css from ~/.config to avoid surprises with XDG paths.
        # wlogout defaults to a very large margin (230px each side). Override so 2x3 fits
        # vertically even with monitor scale 1.5.
        # wlogout buttons expand to fill the grid; increasing margin is the main way
        # to reduce tile size without patching wlogout itself.
        # -n/--no-span keeps the menu on the current monitor.
        # wlogout positions the grid using explicit margins; to vertically center the
        # tiles, tune top/bottom margins. Keep (T+B) constant to preserve tile size,
        # and shift by trading top for bottom.
        "$mod,ESCAPE,exec,sh -lc 'wlogout -n -b 3 -c 20 -r 20 -T 180 -B 340 -L 260 -R 260 -s -l \"$HOME/.config/wlogout/layout\" -C \"$HOME/.config/wlogout/style.css\"'"
        "$mod SHIFT,X,exec,sh -lc 'wlogout -n -b 3 -c 20 -r 20 -T 180 -B 340 -L 260 -R 260 -s -l \"$HOME/.config/wlogout/layout\" -C \"$HOME/.config/wlogout/style.css\"'"
        "$mod SHIFT,L,exec,hyprlock"

        ",Print,exec,hypr-screenshot full"
        "SHIFT,Print,exec,hypr-screenshot region"
        "CTRL,Print,exec,hypr-screenshot full-edit"
        "CTRL SHIFT,Print,exec,hypr-screenshot region-edit"

        "$mod,V,exec,hypr-clipboard"
        "$mod,period,exec,makoctl dismiss"
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
        # Keyboard layouts: English + Russian. Use Caps Lock to toggle between them.
        kb_layout = "us,ru";
        kb_options = "grp:caps_toggle";
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

      windowrulev2 = [
        "float, class:^(float-nmtui)$"
        "center, class:^(float-nmtui)$"
        "size 900 600, class:^(float-nmtui)$"

        "float, class:^(pavucontrol|Pavucontrol|org\\.pulseaudio\\.pavucontrol)$"
        "center, class:^(pavucontrol|Pavucontrol|org\\.pulseaudio\\.pavucontrol)$"
        "size 980 720, class:^(pavucontrol|Pavucontrol|org\\.pulseaudio\\.pavucontrol)$"

        "float, title:^(Volume Control)$"
        "center, title:^(Volume Control)$"
        "size 980 720, title:^(Volume Control)$"
      ];
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
