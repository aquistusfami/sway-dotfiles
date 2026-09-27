#!/usr/bin/env bash
set -euo pipefail

# Check if bluetuith exists
if ! command -v bluetuith >/dev/null 2>&1; then
    notify-send -u critical "Bluetooth" "bluetuith not found."
    exit 1
fi

# Ensure bluetooth is unblocked and powered on
rfkill unblock bluetooth 2>/dev/null || true
bluetoothctl power on >/dev/null 2>&1 || true

# Launch bluetuith TUI in floating foot terminal
foot -a termfloat -T "Bluetooth Manager" bluetuith &
