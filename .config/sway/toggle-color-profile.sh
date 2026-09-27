#!/usr/bin/env bash
set -euo pipefail

# Toggle giữa 2 chế độ màu cho màn OLED ThinkPad P14s
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/sway_color_profile"
CURRENT=$(cat "$STATE_FILE" 2>/dev/null || echo "vibrant")

if [ "$CURRENT" = "vibrant" ]; then
    swaymsg "output eDP-1 color_profile srgb"
    echo "srgb" > "$STATE_FILE"
    notify-send -u low -a "Màu sắc OLED" "🎯 Chế độ: sRGB Chuẩn Màu" "Khóa dải màu sRGB trung thực. Phù hợp: Chỉnh sửa ảnh, chân dung, đồ họa." 2>/dev/null || true
else
    swaymsg "output eDP-1 color_profile --device-primaries srgb"
    echo "vibrant" > "$STATE_FILE"
    notify-send -u low -a "Màu sắc OLED" "🎨 Chế độ: DCI-P3 Rực Rỡ" "Toàn bộ dải màu rộng OLED, màu sâu, tương phản cực cao. Phù hợp: Xem ảnh nghệ thuật, phong cảnh, phim." 2>/dev/null || true
fi
