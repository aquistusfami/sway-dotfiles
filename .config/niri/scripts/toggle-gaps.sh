#!/usr/bin/env bash
set -euo pipefail

NIRI_CONFIG="$(readlink -f "${HOME}/.config/niri/config.kdl")"
WAYBAR_STYLE="$(readlink -f "${HOME}/.config/waybar/style.css")"
FUZZEL_CONFIG="$(readlink -f "${HOME}/.config/fuzzel/fuzzel.ini")"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/desktop_mode_state"

current=$(cat "$STATE_FILE" 2>/dev/null || echo "float")

if [ "$current" = "float" ]; then
    # Mode 1: FULL (k gap, k bo, sát 2 bên)
    sed -i 's/^[[:space:]]*gaps [0-9]\+/    gaps 0/' "$NIRI_CONFIG"
    sed -i 's/^[[:space:]]*geometry-corner-radius [0-9]\+/    geometry-corner-radius 0/' "$NIRI_CONFIG"
    sed -i '/\.modules-left {/,/}/ s/margin-left: [0-9]\+px;/margin-left: 0px;/' "$WAYBAR_STYLE"
    sed -i '/\.modules-right {/,/}/ s/margin-right: [0-9]\+px;/margin-right: 0px;/' "$WAYBAR_STYLE"
    sed -i 's/^radius=[0-9]\+/radius=0/' "$FUZZEL_CONFIG"
    sed -i 's/^selection-radius=[0-9]\+/selection-radius=0/' "$FUZZEL_CONFIG"
    echo "full" > "$STATE_FILE"
else
    # Mode 2: FLOAT (gaps 4, bo tròn 8px, cân đối với windows 4px)
    sed -i 's/^[[:space:]]*gaps [0-9]\+/    gaps 4/' "$NIRI_CONFIG"
    sed -i 's/^[[:space:]]*geometry-corner-radius [0-9]\+/    geometry-corner-radius 8/' "$NIRI_CONFIG"
    sed -i '/\.modules-left {/,/}/ s/margin-left: [0-9]\+px;/margin-left: 4px;/' "$WAYBAR_STYLE"
    sed -i '/\.modules-right {/,/}/ s/margin-right: [0-9]\+px;/margin-right: 4px;/' "$WAYBAR_STYLE"
    sed -i 's/^radius=[0-9]\+/radius=8/' "$FUZZEL_CONFIG"
    sed -i 's/^selection-radius=[0-9]\+/selection-radius=4/' "$FUZZEL_CONFIG"
    echo "float" > "$STATE_FILE"
fi

# Reload Niri & Waybar instantaneously
niri msg action load-config-file >/dev/null 2>&1 || true
pkill -USR2 -f waybar 2>/dev/null || true
