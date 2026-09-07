#!/usr/bin/env bash
set -euo pipefail

# Check if bluetoothctl exists
if ! command -v bluetoothctl >/dev/null 2>&1; then
    notify-send -u critical "Bluetooth" "bluetoothctl not found. Please install bluez."
    exit 1
fi

# Ensure bluetooth is unblocked and powered on
rfkill unblock bluetooth 2>/dev/null || true
bluetoothctl power on >/dev/null 2>&1 || true
bluetoothctl pairable on >/dev/null 2>&1 || true

# 1. Prefer blueman-manager if installed
if command -v blueman-manager >/dev/null 2>&1; then
    blueman-manager &
    exit 0
fi

# 2. Prefer bluetuith if installed
if command -v bluetuith >/dev/null 2>&1; then
    foot --app-id=termfloat -T "Bluetooth Manager" bluetuith &
    exit 0
fi

# 3. Dedicated Real-time Continuous Scanner & Connection Manager
foot --app-id=termfloat -T "Bluetooth Manager" "$HOME/.config/waybar/bluetooth-scanner.py" &
