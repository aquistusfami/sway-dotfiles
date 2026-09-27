#!/usr/bin/env bash
set -euo pipefail

# Run-or-Raise script for Niri
# Usage: ror.sh <app_id_regex> <command_to_launch...>

APP_MATCH="$1"
shift

# Check if window already exists in Niri
WIN_ID=$(niri msg --json windows 2>/dev/null | jq -r --arg app "$APP_MATCH" '.[] | select(.app_id != null and (.app_id | test($app; "i"))) | .id' | head -n 1 || true)

if [ -n "$WIN_ID" ]; then
    niri msg action focus-window --id "$WIN_ID"
else
    exec "$@"
fi
