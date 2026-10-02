#!/usr/bin/env bash
set -euo pipefail

# Kiểm tra trạng thái DND hiện tại của Mako
CURRENT_MODE=$(makoctl mode 2>/dev/null || echo "default")

if echo "$CURRENT_MODE" | grep -qw "dnd"; then
    # Currently ON -> Turn OFF
    makoctl mode -r dnd >/dev/null 2>&1 || true
    notify-send -a "focus-mode" -t 2000 -i preferences-system-notifications \
        "Focus Mode" "○ OFF: Notifications unmuted, display auto-suspend enabled." 2>/dev/null || true
else
    # Currently OFF -> Turn ON
    makoctl mode -a dnd >/dev/null 2>&1 || true
    notify-send -a "focus-mode" -t 2500 -i preferences-system-notifications \
        "Focus Mode" "● ON: Notifications silenced, display kept awake." 2>/dev/null || true
fi
