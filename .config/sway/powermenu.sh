#!/usr/bin/env bash
set -euo pipefail

menu="  Lock
  Suspend
  Reboot
  Shutdown
  Logout
  Cancel"

chosen=$(printf "%s\n" "$menu" | fuzzel --dmenu \
    --hide-prompt \
    --lines 6 \
    --width 20 \
    --vertical-pad 6 \
    --line-height 34 || true)

[ -z "$chosen" ] && exit 0

case "$chosen" in
    *"Lock"*)
        swaylock -f
        ;;
    *"Suspend"*)
        swaylock -f
        sleep 0.5
        loginctl suspend 2>/dev/null || sudo zzz 2>/dev/null || zzz
        ;;
    *"Reboot"*)
        loginctl reboot 2>/dev/null || sudo reboot 2>/dev/null || reboot
        ;;
    *"Shutdown"*)
        loginctl poweroff 2>/dev/null || sudo poweroff 2>/dev/null || poweroff
        ;;
    *"Logout"*)
        swaymsg exit
        ;;
    *"Cancel"*)
        exit 0
        ;;
esac
