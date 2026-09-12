#!/usr/bin/env bash
set -euo pipefail

menu="󰌾  Lock
󰒲  Suspend
󰜉  Reboot
󰐥  Shutdown
󰍃  Logout
󰅖  Cancel"

chosen=$(printf "%s\n" "$menu" | fuzzel --dmenu \
    --hide-prompt \
    --lines 6 \
    --width 18 \
    --horizontal-pad 16 \
    --vertical-pad 8 \
    --line-height 32 || true)

[ -z "$chosen" ] && exit 0

case "$chosen" in
    *"Lock"*)
        swaylock -f
        ;;
    *"Suspend"*)
        swaylock -f
        sleep 0.5
        systemctl suspend
        ;;
    *"Reboot"*)
        systemctl reboot
        ;;
    *"Shutdown"*)
        systemctl poweroff
        ;;
    *"Logout"*)
        swaymsg exit
        ;;
    *"Cancel"*)
        exit 0
        ;;
esac
