#!/usr/bin/env bash
set -euo pipefail

# Dynamic power saver for ThinkPad P14s OLED on Niri
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/niri_screen_power_mode"

set_powersave() {
    niri msg output eDP-1 mode "2880x1800@60" >/dev/null 2>&1 || true
    brightnessctl set 40% >/dev/null 2>&1 || true
    echo "powersave" > "$STATE_FILE"
    notify-send -u low -a "Nguồn Màn Hình" "🔋 Tiết Kiệm Pin: 60Hz (40%)" "Đã hạ tần số quét và độ sáng để tiết kiệm ~3W-5W điện." 2>/dev/null || true
}

set_performance() {
    niri msg output eDP-1 mode "2880x1800@120" >/dev/null 2>&1 || true
    brightnessctl set 70% >/dev/null 2>&1 || true
    echo "performance" > "$STATE_FILE"
    notify-send -u low -a "Nguồn Màn Hình" "⚡ Hiệu Năng Cao: 120Hz (70%)" "Màn hình 120Hz mượt mà, độ sáng tối ưu." 2>/dev/null || true
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
