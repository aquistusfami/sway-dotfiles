#!/usr/bin/env bash
set -euo pipefail

raw="${1:-$HOME}"

# Strip file:// prefix if present
if [[ "$raw" =~ ^file:// ]]; then
    raw="${raw#file://}"
fi

# URL decode if needed (e.g. %20 -> space)
target=$(python3 -c "import urllib.parse, sys; print(urllib.parse.unquote(sys.argv[1]))" "$raw" 2>/dev/null || echo "$raw")

# If target does not exist, default to HOME
if [ ! -e "$target" ]; then
    target="$HOME"
fi

exec foot --app-id=termfloat -T "nnn File Manager" /home/aquistus/.config/nnn/run-nnn.sh "$target"
