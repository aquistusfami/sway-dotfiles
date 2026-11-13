#!/usr/bin/env bash
set -euo pipefail

# Screenshot helper script for Niri
# Modes:
#   area-clipboard   : select area -> copy to clipboard
#   area-file        : select area -> save to ~/Pictures/Screenshots
#   window-clipboard : focused window -> copy to clipboard
#   window-file      : focused window -> save to ~/Pictures/Screenshots
#   full-file        : full screen -> save to ~/Pictures/Screenshots
#   full-clipboard   : full screen -> copy to clipboard

MODE="${1:-area-clipboard}"
SCREENSHOT_DIR="${HOME}/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
TARGET_FILE="${SCREENSHOT_DIR}/Screenshot_${TIMESTAMP}.png"

# Slurp styling matching Acid Dark palette
SLURP_ARGS=(-d -b "#20202080" -c "#ff6ac1ff" -s "#ff6ac120" -w 2)

case "$MODE" in
    area-clipboard)
        GEOM=$(slurp "${SLURP_ARGS[@]}") || exit 0
        [ -z "$GEOM" ] && exit 0
        grim -g "$GEOM" - | wl-copy --type image/png
        notify-send -u low -a "Screenshot" "  Area Copied" "Selected area copied to clipboard" 2>/dev/null || true
        ;;

    area-file)
        GEOM=$(slurp "${SLURP_ARGS[@]}") || exit 0
        [ -z "$GEOM" ] && exit 0
        grim -g "$GEOM" "$TARGET_FILE"
        notify-send -u low -a "Screenshot" "  Screenshot Saved" "$(basename "$TARGET_FILE")" 2>/dev/null || true
        ;;

    window-clipboard)
        # Niri native window screenshot or fallback
        niri msg action screenshot-window 2>/dev/null || {
            grim - | wl-copy --type image/png
        }
        notify-send -u low -a "Screenshot" "  Window Copied" "Window copied to clipboard" 2>/dev/null || true
        ;;

    window-file)
        # Niri native focused-window screenshot; saved to screenshot-path in config.kdl
        niri msg action screenshot-window
        notify-send -u low -a "Screenshot" "  Window Saved" "Focused window saved to $(basename "$SCREENSHOT_DIR")" 2>/dev/null || true
        ;;

    full-file)
        grim "$TARGET_FILE"
        notify-send -u low -a "Screenshot" "  Screenshot Saved" "$(basename "$TARGET_FILE")" 2>/dev/null || true
        ;;

    full-clipboard)
        grim - | wl-copy --type image/png
        notify-send -u low -a "Screenshot" "  Screen Copied" "Full screen copied to clipboard" 2>/dev/null || true
        ;;

    *)
        echo "Usage: $0 {area-clipboard|area-file|window-clipboard|window-file|full-file|full-clipboard}"
        exit 1
        ;;
esac
