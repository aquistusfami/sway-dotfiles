#!/usr/bin/env bash
set -euo pipefail

# Ensure nnn environment variables are always present
export EDITOR="nvim"
export VISUAL="nvim"
export NNN_OPTS="eEdH"
export NNN_OPENER="${HOME}/.config/nnn/open"
export NNN_BMS="d:${HOME}/Downloads;D:${HOME}/Documents;p:${HOME}/Pictures;s:${HOME}/Pictures/Screenshots;w:${HOME}/Pictures/wallpapers;c:${HOME}/.config"
export NNN_COLORS="5236"
export NNN_FCOLORS="c1e2272e006033f7c6d6abc4"

exec nnn "$@"
