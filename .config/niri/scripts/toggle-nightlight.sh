#!/usr/bin/env bash
set -euo pipefail

# Toggle Night Light (Blue light filter / warm temperature)
if pgrep -x wlsunset >/dev/null; then
    pkill -x wlsunset
    notify-send -u low -a "Night Light" "☀️ Night Light: Disabled (6500K)" 2>/dev/null || true
elif pgrep -x gammastep >/dev/null; then
    pkill -x gammastep
    notify-send -u low -a "Night Light" "☀️ Night Light: Disabled (6500K)" 2>/dev/null || true
else
    if command -v wlsunset >/dev/null 2>&1; then
        # 4000K warm night temperature
        wlsunset -t 4000 -T 4001 >/dev/null 2>&1 &
        notify-send -u low -a "Night Light" "🌙 Night Light: Enabled (4000K)" 2>/dev/null || true
    elif command -v gammastep >/dev/null 2>&1; then
        gammastep -O 4000 >/dev/null 2>&1 &
        notify-send -u low -a "Night Light" "🌙 Night Light: Enabled (4000K)" 2>/dev/null || true
    fi
fi
