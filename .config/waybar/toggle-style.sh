#!/bin/sh
CONFIG_DIR="$HOME/.config/waybar"
STATE_FILE="$CONFIG_DIR/.style_state"

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "float" ]; then
    cp "$CONFIG_DIR/config-full.jsonc" "$CONFIG_DIR/config.jsonc"
    cp "$CONFIG_DIR/style-full.css" "$CONFIG_DIR/style.css"
    echo "full" > "$STATE_FILE"
    swaymsg gaps outer all set 0 && swaymsg gaps inner all set 0
else
    cp "$CONFIG_DIR/config-float.jsonc" "$CONFIG_DIR/config.jsonc"
    cp "$CONFIG_DIR/style-float.css" "$CONFIG_DIR/style.css"
    echo "float" > "$STATE_FILE"
    swaymsg gaps outer all set 0 && swaymsg gaps inner all set 5
fi

pkill -USR2 -x waybar
