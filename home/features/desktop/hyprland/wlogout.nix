{ pkgs, ... }:
let
  catppuccinWlogout = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "wlogout";
    rev = "b51d7189efb414fc76cb6c08f27c0c69706b9f78";
    hash = "sha256-0VCk+7t/cSEmcnfvKdxUDwwrtK0VLhZrVpw4enoBEbc=";
  };

  # wlogout is a GTK app and may not have an SVG loader in its runtime closure.
  # Generate PNGs from the Catppuccin SVGs so icons always render.
  catppuccinWlogoutPngIcons =
    pkgs.runCommand "catppuccin-wlogout-icons-mocha-blue-png" { nativeBuildInputs = [ pkgs.librsvg ]; }
      ''
        mkdir -p "$out"
        for name in lock logout suspend hibernate reboot shutdown; do
          rsvg-convert -w 256 -h 256 \
            "${catppuccinWlogout}/icons/wlogout/mocha/blue/$name.svg" \
            -o "$out/$name.png"
        done
      '';
in
{
  home.packages = [ pkgs.wlogout ];
  xdg = {
    configFile = {
      "wlogout/layout".text = ''
        {
          "label" : "lock",
          "action" : "hyprlock",
          "text" : "Lock ",
          "keybind" : "l"
        }
        {
          "label" : "logout",
          "action" : "hyprctl dispatch exit",
          "text" : "Logout ",
          "keybind" : "e"
        }
        {
          "label" : "suspend",
          "action" : "systemctl suspend",
          "text" : "Suspend ",
          "keybind" : "s"
        }
        {
          "label" : "hibernate",
          "action" : "systemctl hibernate",
          "text" : "Hibernate ",
          "keybind" : "h"
        }
        {
          "label" : "reboot",
          "action" : "systemctl reboot",
          "text" : "Reboot ",
          "keybind" : "r"
        }
        {
          "label" : "shutdown",
          "action" : "systemctl poweroff",
          "text" : "Shutdown ",
          "keybind" : "p"
        }
      '';

      # Catppuccin Mocha + Blue icons (PNGs for maximum compatibility)
      "wlogout/icons/lock.png".source = "${catppuccinWlogoutPngIcons}/lock.png";
      "wlogout/icons/logout.png".source = "${catppuccinWlogoutPngIcons}/logout.png";
      "wlogout/icons/suspend.png".source = "${catppuccinWlogoutPngIcons}/suspend.png";
      "wlogout/icons/hibernate.png".source = "${catppuccinWlogoutPngIcons}/hibernate.png";
      "wlogout/icons/reboot.png".source = "${catppuccinWlogoutPngIcons}/reboot.png";
      "wlogout/icons/shutdown.png".source = "${catppuccinWlogoutPngIcons}/shutdown.png";

      "wlogout/style.css".text = ''
        /* GTK3 does not support CSS custom properties (var(--x)).
         * Use @define-color so styling + icons parse reliably.
         */
        @define-color ctp_text #cdd6f4;
        @define-color ctp_overlay0 #6c7086;
        @define-color ctp_surface0 #313244;
        @define-color ctp_mantle #181825;
        @define-color ctp_crust #11111b;

        /* Accents */
        @define-color ctp_blue #89b4fa;
        @define-color ctp_lavender #b4befe;
        @define-color ctp_teal #94e2d5;
        @define-color ctp_mauve #cba6f7;
        @define-color ctp_peach #fab387;
        @define-color ctp_red #f38ba8;

        * {
          font-family: Fira Sans, FiraMono Nerd Font;
          font-size: 10pt;
          box-shadow: none;
        }

        window {
          background-color: alpha(@ctp_crust, 0.92);
        }

        button {
          min-width: 120px;
          min-height: 120px;

          /* Spacing is primarily handled by wlogout's -c / -r flags (grid spacing). */
          margin: 0;
          /* Labels stay at the bottom (wlogout hardcodes label yalign=0.9).
           * Reserve top space for the icon so it never overlaps the label.
           */
          padding: 74px 10px 10px 10px;

          border-radius: 12px;
          border-style: solid;
          border-width: 2px;
          border-color: alpha(@ctp_overlay0, 0.65);

          color: @ctp_text;
          text-decoration-color: @ctp_text;
          background-color: alpha(@ctp_mantle, 0.72);

          background-repeat: no-repeat;
          /* Big icon without overlapping the bottom label */
          background-position: center 30%;
          background-size: 64px 64px;
        }

        button:focus,
        button:active,
        button:hover {
          outline-style: none;
          background-color: alpha(@ctp_surface0, 0.82);
        }

        /* Ensure label doesn't paint over the icon (some themes do). */
        button label {
          background-color: transparent;
        }

        /* Icons
         * Use Nix store paths to avoid any ambiguity about relative URL resolution.
         */
        button#lock {
          background-image: url("${catppuccinWlogoutPngIcons}/lock.png");
        }
        button#logout {
          background-image: url("${catppuccinWlogoutPngIcons}/logout.png");
        }
        button#suspend {
          background-image: url("${catppuccinWlogoutPngIcons}/suspend.png");
        }
        button#hibernate {
          background-image: url("${catppuccinWlogoutPngIcons}/hibernate.png");
        }
        button#reboot {
          background-image: url("${catppuccinWlogoutPngIcons}/reboot.png");
        }
        button#shutdown {
          background-image: url("${catppuccinWlogoutPngIcons}/shutdown.png");
        }

        /* Per-action hover/focus accents */
        button#lock:focus, button#lock:hover { border-color: @ctp_blue; }
        button#logout:focus, button#logout:hover { border-color: @ctp_lavender; }
        button#suspend:focus, button#suspend:hover { border-color: @ctp_teal; }
        button#hibernate:focus, button#hibernate:hover { border-color: @ctp_mauve; }
        button#reboot:focus, button#reboot:hover { border-color: @ctp_peach; }
        button#shutdown:focus, button#shutdown:hover { border-color: @ctp_red; }
      '';
    };
  };
}
