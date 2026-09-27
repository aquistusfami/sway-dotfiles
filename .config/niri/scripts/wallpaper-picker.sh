#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="${HOME}/Pictures/wallpapers"
[ -d "$WALL_DIR" ] || exit 0

# Window dimensions
ww=1000
wh=700

if ! command -v swayimg >/dev/null 2>&1; then
    notify-send -a "Wallpaper" "swayimg is not installed" "Please install swayimg"
    exit 1
fi

exec swayimg -g \
  --appid=wallpaper-picker \
  -S "${ww},${wh}" \
  -c "${HOME}/.config/niri/scripts/wallpaper-picker.lua" \
  "$WALL_DIR"
