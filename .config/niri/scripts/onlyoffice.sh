#!/usr/bin/env bash
# onlyoffice-wayland.sh — Launch OnlyOffice under XWayland inside Niri
# Starts Xwayland on :1 if not already running, then launches OnlyOffice

DISPLAY_NUM=":1"

# Start Xwayland if not running
if ! pgrep -x Xwayland > /dev/null; then
    Xwayland "$DISPLAY_NUM" -rootless -wm 0 &
    sleep 1
fi

DISPLAY="$DISPLAY_NUM" onlyoffice-desktopeditors "$@" &
