#!/bin/sh
STATE_FILE="${HOME}/.config/sway/.gaps_state"

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "0" ]; then
    swaymsg gaps outer all set 0 && swaymsg gaps inner all set 5
    echo "5" > "$STATE_FILE"
else
    swaymsg gaps outer all set 0 && swaymsg gaps inner all set 0
    echo "0" > "$STATE_FILE"
fi
