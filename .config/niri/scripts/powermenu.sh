#!/usr/bin/env bash
set -euo pipefail

# Dedicated Power Menu for Niri on NixOS
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
        sleep 0.3
        systemctl suspend
        ;;
    *"Reboot"*)
        systemctl reboot
        ;;
    *"Shutdown"*)
        systemctl poweroff
        ;;
    *"Logout"*)
        niri msg action quit --skip-confirmation
        ;;
    *"Cancel"*)
        exit 0
        ;;
esac
