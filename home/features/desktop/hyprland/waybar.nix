{ pkgs, ... }:
let
  waybarNowPlaying =
    pkgs.writeShellScriptBin "waybar-nowplaying" ''
      set -euo pipefail

      players="$(${pkgs.playerctl}/bin/playerctl -l 2>/dev/null || true)"
      if [ -z "$players" ]; then
        ${pkgs.coreutils}/bin/printf '{"text":"","tooltip":"No media players"}\n'
        exit 0
      fi

      pick=""
      while IFS= read -r p; do
        [ -n "$p" ] || continue
        st="$(${pkgs.playerctl}/bin/playerctl -p "$p" status 2>/dev/null || true)"
        if [ "$st" = "Playing" ]; then
          pick="$p"
          break
        fi
      done <<< "$players"

      if [ -z "$pick" ]; then
        pick="$(${pkgs.coreutils}/bin/printf "%s\n" "$players" | ${pkgs.coreutils}/bin/head -n1)"
      fi

      status="$(${pkgs.playerctl}/bin/playerctl -p "$pick" status 2>/dev/null || true)"
      meta="$(${pkgs.playerctl}/bin/playerctl -p "$pick" metadata --format '{{artist}} — {{title}}' 2>/dev/null || true)"
      if [ -z "$meta" ] || [ "$meta" = " — " ]; then
        meta="$(${pkgs.playerctl}/bin/playerctl -p "$pick" metadata --format '{{title}}' 2>/dev/null || true)"
      fi
      if [ -z "$meta" ]; then
        meta="$pick"
      fi

      icon=""
      if [ "$status" = "Playing" ]; then icon=""; fi
      if [ "$status" = "Paused" ]; then icon=""; fi

      max=40
      text="$meta"
      if [ "''${#text}" -gt "$max" ]; then
        text="''${text:0:$((max-1))}…"
      fi

      tooltip="$meta\nPlayer: $pick\nStatus: $status"
      ${pkgs.jq}/bin/jq -cn --arg text "$icon $text" --arg tooltip "$tooltip" '{text:$text, tooltip:$tooltip}'
    '';

  waybarPlayerctl =
    pkgs.writeShellScriptBin "waybar-playerctl" ''
      set -euo pipefail

      cmd="''${1:-}"
      if [ -z "$cmd" ]; then
        exit 2
      fi

      players="$(${pkgs.playerctl}/bin/playerctl -l 2>/dev/null || true)"
      [ -n "$players" ] || exit 0

      pick=""
      while IFS= read -r p; do
        [ -n "$p" ] || continue
        st="$(${pkgs.playerctl}/bin/playerctl -p "$p" status 2>/dev/null || true)"
        if [ "$st" = "Playing" ]; then
          pick="$p"
          break
        fi
      done <<< "$players"

      if [ -z "$pick" ]; then
        pick="$(${pkgs.coreutils}/bin/printf "%s\n" "$players" | ${pkgs.coreutils}/bin/head -n1)"
      fi

      ${pkgs.playerctl}/bin/playerctl -p "$pick" "$cmd"
    '';
in
{
  home.packages = [ pkgs.waybar ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
      {
        layer = "top";
        position = "top";
        height = 28;
        spacing = 6;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "custom/nowplaying" ];
        modules-right = [
          "network"
          "pulseaudio"
          "battery"
          "clock"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          all-outputs = true;
          disable-scroll = true;
          "persistent-workspaces" = {
            "*" = [
              1
              2
              3
              4
              5
              6
              7
              8
              9
            ];
          };
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 80;
          separate-outputs = true;
        };

        clock = {
          format = "{:%I:%M %p}";
          tooltip-format = "{:%a %d %b %Y  %I:%M:%S %p}";
        };

        network = {
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  offline";
          tooltip = true;
          # nmtui uses newt; force readable colors explicitly (systemd env doesn't always
          # reach subprocesses the way we want).
          on-click = "sh -lc 'env TERM=xterm-256color NEWT_COLORS=\"$NEWT_COLORS\" kitty --class float-nmtui --title nmtui -e nmtui'";
        };

        "custom/nowplaying" = {
          exec = "${waybarNowPlaying}/bin/waybar-nowplaying";
          return-type = "json";
          interval = 1;
          on-click = "${waybarPlayerctl}/bin/waybar-playerctl play-pause";
          on-click-right = "${waybarPlayerctl}/bin/waybar-playerctl next";
          on-click-middle = "${waybarPlayerctl}/bin/waybar-playerctl previous";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰖁 muted";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "pavucontrol";
          on-click-right = "pamixer -t";
          scroll-step = 0;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        tray = {
          spacing = 10;
          icon-size = 16;
          icons = {
            cursor = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24/apps/vscode.svg";
            Cursor = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24/apps/vscode.svg";
            "cursor.desktop" = "${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/24x24/apps/vscode.svg";
          };
        };
      }
    ];

    style = ''
      * {
        font-family: Fira Sans, FiraMono Nerd Font;
        font-size: 10pt;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: rgba(17, 17, 27, 0.90);
        color: rgba(205, 214, 244, 1.0);
      }

      #workspaces button {
        padding: 0 4px;
        margin: 3px 1px;
        border-radius: 6px;
        background: transparent;
        color: rgba(205, 214, 244, 0.80);
      }

      #workspaces button.active {
        background: rgba(88, 91, 112, 0.70);
        color: rgba(205, 214, 244, 1.0);
      }

      #workspaces button.urgent {
        background: rgba(243, 139, 168, 0.85);
        color: rgba(17, 17, 27, 1.0);
      }

      #clock,
      #network,
      #custom-nowplaying,
      #pulseaudio,
      #battery,
      #tray,
      #window {
        padding: 0 8px;
        margin: 4px 0;
        border-radius: 9px;
        background: rgba(30, 30, 46, 0.55);
      }

      #window {
        background: rgba(30, 30, 46, 0.35);
      }

      #custom-nowplaying {
        background: rgba(30, 30, 46, 0.35);
      }

      #tray {
        background: rgba(205, 214, 244, 0.10);
      }

      #tray > * {
        margin: 0 4px;
      }

      tooltip {
        background: rgba(17, 17, 27, 0.92);
        color: rgba(205, 214, 244, 1.0);
        border-radius: 9px;
        border: 2px solid rgba(88, 91, 112, 0.80);
        padding: 8px;
      }

      tooltip label {
        color: rgba(205, 214, 244, 1.0);
      }
    '';
  };
}
