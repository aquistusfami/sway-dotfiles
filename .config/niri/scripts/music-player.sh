#!/usr/bin/env bash
set -euo pipefail

# Ensure MPD is running
if ! pgrep -x mpd >/dev/null 2>&1; then
    mpd "${HOME}/.config/mpd/mpd.conf" 2>/dev/null || true
    sleep 0.2
fi

# Ensure mpd-mpris is running for media keys
if ! pgrep -f mpd-mpris >/dev/null 2>&1; then
    mpd-mpris >/dev/null 2>&1 &
fi

exec rmpc "$@"
