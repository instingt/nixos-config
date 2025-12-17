{ pkgs, ... }:
let
  batteryNotify =
    pkgs.writeShellScript "battery-notify" ''
      set -euo pipefail

      cache_dir="''${XDG_CACHE_HOME:-$HOME/.cache}"
      state_file="$cache_dir/battery-notify.state"
      ${pkgs.coreutils}/bin/mkdir -p "$cache_dir"

      bat=""
      for b in /sys/class/power_supply/BAT*; do
        [ -d "$b" ] || continue
        if [ "$(${pkgs.coreutils}/bin/cat "$b/type" 2>/dev/null || true)" = "Battery" ]; then
          bat="$b"
          break
        fi
      done

      # No battery (desktop), nothing to do.
      [ -n "$bat" ] || exit 0

      cap="$(${pkgs.coreutils}/bin/cat "$bat/capacity")"
      status="$(${pkgs.coreutils}/bin/cat "$bat/status")"

      # Avoid noise while charging / full / unknown.
      if [ "$status" != "Discharging" ]; then
        ${pkgs.coreutils}/bin/printf "ok\n" > "$state_file"
        exit 0
      fi

      last="$(${pkgs.coreutils}/bin/cat "$state_file" 2>/dev/null || ${pkgs.coreutils}/bin/printf "ok")"

      state="ok"
      urgency="normal"
      title=""
      body=""

      # Requested thresholds: less than 30% and less than 15%.
      if [ "$cap" -lt 15 ]; then
        state="critical"
        urgency="critical"
        title="Battery critical"
        body="Battery at $cap%. Please plug in power."
      elif [ "$cap" -lt 30 ]; then
        state="low"
        urgency="normal"
        title="Battery low"
        body="Battery at $cap%."
      fi

      if [ "$state" = "ok" ]; then
        ${pkgs.coreutils}/bin/printf "ok\n" > "$state_file"
        exit 0
      fi

      # Rate-limit: only notify on state transitions (ok->low, low->critical, ok->critical).
      if [ "$state" != "$last" ]; then
        ${pkgs.libnotify}/bin/notify-send -u "$urgency" "$title" "$body"
      fi

      ${pkgs.coreutils}/bin/printf "%s\n" "$state" > "$state_file"
    '';
in
{
  home.packages = [ pkgs.libnotify ];

  systemd.user.services.battery-notify = {
    Unit = {
      Description = "Battery level notifications (<30% low, <15% critical)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = batteryNotify;
    };
  };

  systemd.user.timers.battery-notify = {
    Unit = {
      Description = "Battery level notification timer";
    };
    Timer = {
      OnBootSec = "2m";
      OnUnitActiveSec = "2m";
      AccuracySec = "30s";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}


