#!/usr/bin/env bash
set -euo pipefail

pick="$(
  cliphist list | wofi --dmenu --prompt 'Clipboard'
)"

if [[ -z "${pick}" ]]; then
  exit 0
fi

cliphist decode <<<"$pick" | wl-copy
notify-send -a clipboard "Clipboard" "Copied selection"


