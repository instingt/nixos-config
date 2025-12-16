{ pkgs, lib, ... }:
{
  home.packages = [
    pkgs.code-cursor
  ];

  # Cursor is packaged/updated by Nix; disable in-app updater nags.
  home.activation.cursorDisableUpdater =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      settings_dir="$HOME/.config/Cursor/User"
      settings_json="$settings_dir/settings.json"

      mkdir -p "$settings_dir"

      # Merge settings without clobbering existing user config.
      if [ -f "$settings_json" ]; then
        tmp="$(mktemp)"
        if ${pkgs.jq}/bin/jq \
          '. + {
            "update.mode": "none",
            "update.showReleaseNotes": false,
            "extensions.autoCheckUpdates": false,
            "extensions.autoUpdate": false
          }' \
          "$settings_json" > "$tmp"; then
          mv "$tmp" "$settings_json"
        else
          rm -f "$tmp"
          mv "$settings_json" "$settings_json.bak"
          ${pkgs.jq}/bin/jq -n \
            '{
              "update.mode": "none",
              "update.showReleaseNotes": false,
              "extensions.autoCheckUpdates": false,
              "extensions.autoUpdate": false
            }' > "$settings_json"
        fi
      else
        ${pkgs.jq}/bin/jq -n \
          '{
            "update.mode": "none",
            "update.showReleaseNotes": false,
            "extensions.autoCheckUpdates": false,
            "extensions.autoUpdate": false
          }' > "$settings_json"
      fi
    '';
}
