#!/bin/sh

[ "$1" = "-c" ] && shift
query="$*"

[ -n "$query" ] && exec goldendict "$query"
