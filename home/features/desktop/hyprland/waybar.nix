{ pkgs, ... }:
{
  home.packages = [ pkgs.waybar ];

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = [
      {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 10;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right = [
          "network"
          "pulseaudio"
          "battery"
          "tray"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          all-outputs = true;
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 80;
          separate-outputs = true;
        };

        clock = {
          format = "{:%a %b %d  %H:%M}";
          tooltip-format = "{:%Y-%m-%d %H:%M:%S}";
        };

        network = {
          format-wifi = "  {essid} ({signalStrength}%)";
          format-ethernet = "󰈀  {ipaddr}";
          format-disconnected = "󰖪  offline";
          tooltip = true;
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
          on-click = "pamixer -t";
          scroll-step = 5;
        };

        battery = {
          states = {
            warning = 20;
            critical = 10;
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
        };
      }
    ];

    style = ''
      * {
        font-family: Fira Sans, FiraMono Nerd Font;
        font-size: 11pt;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: rgba(17, 17, 27, 0.90);
        color: rgba(205, 214, 244, 1.0);
      }

      #workspaces button {
        padding: 0 8px;
        margin: 6px 2px;
        border-radius: 8px;
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
      #pulseaudio,
      #battery,
      #tray,
      #window {
        padding: 0 10px;
        margin: 6px 0;
        border-radius: 10px;
        background: rgba(30, 30, 46, 0.55);
      }

      #window {
        background: rgba(30, 30, 46, 0.35);
      }
    '';
  };
}
