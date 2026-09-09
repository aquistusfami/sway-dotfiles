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

# Launch Dedicated Real-time Continuous Scanner & Connection Manager (Dotfiles TUI)
footclient -a termfloat -T "Bluetooth Manager" "$HOME/.config/waybar/bluetooth-scanner.py" || foot --app-id=termfloat -T "Bluetooth Manager" "$HOME/.config/waybar/bluetooth-scanner.py" &
