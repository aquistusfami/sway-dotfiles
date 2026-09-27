#!/usr/bin/env bash
set -euo pipefail

# Find waybar PIDs
PIDS=$(pidof waybar 2>/dev/null || pidof .waybar-wrapped 2>/dev/null || true)

if [ -n "$PIDS" ]; then
    FIRST_PID=$(echo "$PIDS" | awk '{print $1}')
    EXTRA_PIDS=$(echo "$PIDS" | cut -s -d' ' -f2- || true)
    if [ -n "$EXTRA_PIDS" ]; then
        kill -9 $EXTRA_PIDS 2>/dev/null || true
    fi
    # Toggle visibility
    kill -USR1 "$FIRST_PID"
else
    waybar >/dev/null 2>&1 &
fi
