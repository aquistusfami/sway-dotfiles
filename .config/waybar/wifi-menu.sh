#!/usr/bin/env bash
set -euo pipefail

# Check if nmcli exists
if ! command -v nmcli >/dev/null 2>&1; then
    notify-send -u critical "Wi-Fi" "nmcli not found. Please install NetworkManager."
    exit 1
fi

# Ensure Wi-Fi radio is unblocked and powered on
rfkill unblock wifi 2>/dev/null || true
nmcli radio wifi on >/dev/null 2>&1 || true

# Launch dedicated Real-time Continuous Scanner & Connection Manager
footclient -a termfloat -T "Wi-Fi Manager" "$HOME/.config/waybar/wifi-scanner.py" || foot --app-id=termfloat -T "Wi-Fi Manager" "$HOME/.config/waybar/wifi-scanner.py" &
