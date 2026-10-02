#!/usr/bin/env bash
set -euo pipefail

# Dynamic power saver for ThinkPad P14s OLED on Niri
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri_screen_power_mode"

is_edp_active() {
    niri msg outputs 2>/dev/null | awk '/\(eDP-1\)/{getline; if ($1 == "Disabled") exit 1; exit 0}'
}

set_powersave() {
    if is_edp_active; then
        niri msg output eDP-1 mode "2880x1800@60" >/dev/null 2>&1 || true
        brightnessctl set 40% >/dev/null 2>&1 || true
        notify-send -u low -a "Display Power" "🔋 Battery Saver: 60Hz (40%)" "Reduced refresh rate & brightness to save power." 2>/dev/null || true
    fi
    echo "powersave" > "$STATE_FILE"
}

set_performance() {
    if is_edp_active; then
        niri msg output eDP-1 mode "2880x1800@120" >/dev/null 2>&1 || true
        brightnessctl set 70% >/dev/null 2>&1 || true
        notify-send -u low -a "Display Power" "⚡ High Performance: 120Hz (70%)" "Smooth 120Hz display with optimal brightness." 2>/dev/null || true
    fi
    echo "performance" > "$STATE_FILE"
}

auto_detect() {
    local ac_online
    ac_online=$(cat /sys/class/power_supply/AC/online 2>/dev/null || cat /sys/class/power_supply/ACAD/online 2>/dev/null || echo "1")
    if [ "$ac_online" = "0" ]; then
        set_powersave
    else
        set_performance
    fi
}

toggle() {
    local current
    current=$(cat "$STATE_FILE" 2>/dev/null || echo "performance")
    if [ "$current" = "performance" ]; then
        set_powersave
    else
        set_performance
    fi
}

watch() {
    auto_detect
    udevadm monitor --udev --subsystem-match=power_supply 2>/dev/null | while read -r line; do
        if echo "$line" | grep -q "change"; then
            sleep 1
            auto_detect
        fi
    done
}

case "${1:-toggle}" in
    toggle) toggle ;;
    powersave) set_powersave ;;
    performance) set_performance ;;
    auto) auto_detect ;;
    watch) watch ;;
    *) toggle ;;
esac
