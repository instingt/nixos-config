{ pkgs, ... }:
{
  home.packages = [ pkgs.hypridle ];

  xdg.configFile."hypr/hypridle.conf".text = ''
    general {
      lock_cmd = hyprlock
      before_sleep_cmd = hyprlock
      after_sleep_cmd = hyprctl dispatch dpms on
    }

    # Lock after 10 minutes idle
    listener {
      timeout = 600
      on-timeout = hyprlock
    }

    # Turn displays off after 15 minutes idle, turn back on when input resumes
    listener {
      timeout = 900
      on-timeout = hyprctl dispatch dpms off
      on-resume = hyprctl dispatch dpms on
    }
  '';
}
