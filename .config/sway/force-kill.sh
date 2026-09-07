#!/usr/bin/env bash
set -euo pipefail

# Find PID of currently focused window container in Sway
pid=$(swaymsg -t get_tree 2>/dev/null | awk '
BEGIN { depth = 0; }
/{/ {
    depth++;
    node_focused[depth] = 0;
    node_pid[depth] = 0;
}
/"focused":[[:space:]]*true/ {
    node_focused[depth] = 1;
}
/"pid":[[:space:]]*[0-9]+/ {
    match($0, /[0-9]+/);
    node_pid[depth] = substr($0, RSTART, RLENGTH);
}
/}/ {
    if (node_focused[depth] && node_pid[depth] > 0) {
        print node_pid[depth];
        exit;
    }
    depth--;
}
' || true)

# First notify Sway to close container
swaymsg kill 2>/dev/null || true

# If a valid application PID exists, forcefully kill the process and its children
if [ -n "$pid" ] && [ "$pid" -gt 1 ]; then
    pkill -9 -P "$pid" 2>/dev/null || true
    kill -9 "$pid" 2>/dev/null || true
fi
