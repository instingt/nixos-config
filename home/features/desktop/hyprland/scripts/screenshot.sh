#!/usr/bin/env bash
set -euo pipefail

mode="${1:-region}"

dir="${XDG_PICTURES_DIR:-$HOME/Pictures}/Screenshots"
mkdir -p "$dir"

ts="$(date +%F_%H-%M-%S)"
file="$dir/$ts.png"

edit=0
case "$mode" in
  full) ;;
  region) geometry="$(slurp)" ;;
  full-edit) edit=1 ;;
  region-edit) geometry="$(slurp)"; edit=1 ;;
  *)
    echo "usage: screenshot.sh [full|region|full-edit|region-edit]" >&2
    exit 2
    ;;
esac

if [[ -n "${geometry:-}" ]]; then
  grim -g "$geometry" "$file"
else
  grim "$file"
fi

wl-copy < "$file"
notify-send -a screenshot "Screenshot saved" "$file"

if [[ "$edit" -eq 1 ]]; then
  swappy -f "$file" -o "$file"
  wl-copy < "$file"
  notify-send -a screenshot "Screenshot updated" "$file"
fi


