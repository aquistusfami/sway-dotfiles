#!/usr/bin/env bash
# onlyoffice-wayland.sh — Launch OnlyOffice under XWayland inside Niri

DISPLAY_NUM=":1"

# Start Xwayland if not running (noreset keeps it alive between app launches)
if ! pgrep -x Xwayland > /dev/null 2>&1; then
    Xwayland "$DISPLAY_NUM" \
        -rootless \
        -wm 0 \
        -noreset \
        -listen tcp \
        +extension RANDR &
    sleep 2
fi

exec env DISPLAY="$DISPLAY_NUM" onlyoffice-desktopeditors "$@"
