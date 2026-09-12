# Environment variables for Zsh login shells
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.local/bin:$HOME/.gemini/antigravity-cli/bin:$DOTNET_ROOT:$DOTNET_ROOT/tools:$PATH"
export NO_AT_BRIDGE=1
export MOZ_ENABLE_WAYLAND=1
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24
export EDITOR=nvim
export VISUAL=nvim

# Input method (Fcitx5 for Wayland/Sway)
export XMODIFIERS="@im=fcitx"
export GTK_IM_MODULE="fcitx"
export QT_IM_MODULE="fcitx"

# nnn File Manager configuration
export NNN_OPTS="eEd"
export NNN_OPENER="$HOME/.config/nnn/open"
export NNN_BMS="d:$HOME/Downloads;D:$HOME/Documents;p:$HOME/Pictures;s:$HOME/Pictures/Screenshots;w:$HOME/Pictures/wallpapers;c:$HOME/.config"
export NNN_COLORS="5236"
export NNN_FCOLORS="c1e2272e006033f7c6d6abc4"

# Ensure DBus user session bus
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR:-/run/user/$UID}/bus"
if [ ! -S "${XDG_RUNTIME_DIR:-/run/user/$UID}/bus" ]; then
    dbus-daemon --session --address="$DBUS_SESSION_BUS_ADDRESS" --fork --nopidfile 2>/dev/null || true
fi

# Auto-start Sway on TTY1 login
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    exec sway
fi
