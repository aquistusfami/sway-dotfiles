#!/usr/bin/env bash
set -euo pipefail

# Try graceful close first via niri
niri msg action close-window 2>/dev/null || true

# Try to get focused window PID from niri
pid=$(niri msg --json focused-window 2>/dev/null | jq -r '.pid // empty' 2>/dev/null || true)

# If a valid application PID exists, forcefully kill the process and its children
if [ -n "$pid" ] && [ "$pid" -gt 1 ]; then
    pkill -9 -P "$pid" 2>/dev/null || true
    kill -9 "$pid" 2>/dev/null || true
fi
