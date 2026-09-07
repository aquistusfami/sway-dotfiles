#!/usr/bin/env bash
set -euo pipefail

WALL_DIR="${HOME}/Pictures/wallpapers"
THUMB_DIR="${HOME}/.cache/wallpaper_thumbs"
CURRENT_WALL="${HOME}/.config/sway/current_wallpaper"

mkdir -p "$WALL_DIR" "$THUMB_DIR"

# Generate missing or updated thumbnails using gdk-pixbuf-thumbnailer
for img in "$WALL_DIR"/*; do
  [ -f "$img" ] || continue
  fname=$(basename "$img")
  ext="${fname##*.}"
  case "$ext" in
    png|jpg|jpeg|PNG|JPG|JPEG|webp|WEBP) ;;
    *) continue ;;
  esac

  thumb="$THUMB_DIR/${fname%.*}.png"
  if [ ! -f "$thumb" ] || [ "$img" -nt "$thumb" ]; then
    /usr/bin/gdk-pixbuf-thumbnailer -s 128 "$img" "$thumb" 2>/dev/null || true
  fi
done

# Build entry list for Fuzzel in dmenu mode with icon thumbnails
entries=""
while IFS= read -r img; do
  [ -f "$img" ] || continue
  fname=$(basename "$img")
  title="${fname%.*}"
  thumb="$THUMB_DIR/${title}.png"

  if [ -f "$thumb" ]; then
    entries+="${title}\0icon\x1f${thumb}\n"
  else
    entries+="${title}\n"
  fi
done < <(find "$WALL_DIR" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.webp" \) | sort)

if [ -z "$entries" ]; then
  exit 0
fi

# Show squared Fuzzel picker with large thumbnails
selected=$(printf "%b" "$entries" | fuzzel --dmenu \
  --prompt " Wallpaper: " \
  --lines 8 \
  --width 50 \
  --line-height 52)

[ -z "$selected" ] && exit 0

# Find selected file
chosen_img=""
for img in "$WALL_DIR"/"$selected".*; do
  if [ -f "$img" ]; then
    chosen_img="$img"
    break
  fi
done

if [ -n "$chosen_img" ] && [ -f "$chosen_img" ]; then
  ln -sf "$chosen_img" "$CURRENT_WALL"
  swaymsg "output * bg \"$CURRENT_WALL\" fill"
fi
