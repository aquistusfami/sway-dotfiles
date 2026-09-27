#!/usr/bin/env bash
set -euo pipefail

IMAGE_PATH="$1"
MODE="${2:-fill}"

[ -f "$IMAGE_PATH" ] || exit 1

# Update symlinks for persistence and swaylock
mkdir -p "$HOME/.config/niri" "$HOME/.config/sway"
ln -sf "$IMAGE_PATH" "$HOME/.config/niri/current_wallpaper"
ln -sf "$IMAGE_PATH" "$HOME/.config/sway/current_wallpaper" 2>/dev/null || true

# Terminate existing swaybg instances cleanly and immediately
pkill -9 -f swaybg 2>/dev/null || true
sleep 0.05

# Spawn swaybg via niri compositor
niri msg action spawn -- swaybg -i "$IMAGE_PATH" -m "$MODE"

# Notification
FILENAME="$(basename "$IMAGE_PATH")"
notify-send -i "$IMAGE_PATH" -a "Wallpaper" "Wallpaper Changed (${MODE^^})" "$FILENAME" 2>/dev/null || true
