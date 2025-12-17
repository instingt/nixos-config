{ pkgs, ... }:
{
  home.packages = [ pkgs.hyprlock ];

  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
      disable_loading_bar = true
      hide_cursor = true
      grace = 0
      no_fade_in = false
    }

    background {
      monitor =
      color = rgba(17, 17, 27, 1.0)
    }

    label {
      monitor =
      text = cmd[update:1000] date +%H:%M
      color = rgba(205, 214, 244, 1.0)
      font_size = 72
      font_family = Fira Sans
      position = 0, 120
      halign = center
      valign = center
    }

    label {
      monitor =
      text = cmd[update:1000] date +%A,\\ %B\\ %d
      color = rgba(205, 214, 244, 0.85)
      font_size = 22
      font_family = Fira Sans
      position = 0, 60
      halign = center
      valign = center
    }

    input-field {
      monitor =
      size = 360, 54
      outline_thickness = 2
      dots_size = 0.22
      dots_spacing = 0.20
      dots_center = true
      fade_on_empty = false
      rounding = 12

      outer_color = rgba(88, 91, 112, 0.80)
      inner_color = rgba(30, 30, 46, 0.60)
      font_color = rgba(205, 214, 244, 1.0)

      placeholder_text = Password
      position = 0, -60
      halign = center
      valign = center
    }
  '';
}
