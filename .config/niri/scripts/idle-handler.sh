#!/usr/bin/env bash
set -euo pipefail

pkill -x swayidle 2>/dev/null || true
sleep 0.2

# Tự động khóa màn hình sau 5 phút, tắt màn hình sau 10 phút nếu rảnh
# Sẽ tự động bị chặn lại khi Focus Mode bật (Waybar idle_inhibitor)
exec swayidle -w \
    timeout 300 'swaylock -f' \
    timeout 600 'niri msg action power-off-monitors' \
    resume 'niri msg action power-on-monitors' \
    before-sleep 'swaylock -f' \
    lock 'swaylock -f'
