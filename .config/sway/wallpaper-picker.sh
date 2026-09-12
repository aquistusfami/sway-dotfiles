#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="${HOME}/Pictures/wallpapers"
[ -d "$WALL_DIR" ] || exit 0

# Window dimensions
ww=1000
wh=700

# Calculate exact center on active (focused) output
read -r ox oy ow oh < <(swaymsg -t get_outputs | jq -r '.[] | select(.focused) | "\(.rect.x) \(.rect.y) \(.rect.width) \(.rect.height)"' 2>/dev/null || echo "0 0 1920 1080")
pos_x=$(( ox + (ow - ww) / 2 ))
pos_y=$(( oy + (oh - wh) / 2 ))

exec swayimg -g \
  --appid=wallpaper-picker \
  -S "${ww},${wh}" \
  -P "${pos_x},${pos_y}" \
  -c "${HOME}/.config/sway/wallpaper-picker.lua" \
  "$WALL_DIR"
