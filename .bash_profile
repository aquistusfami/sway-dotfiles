# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc


# Added by Antigravity CLI installer
export PATH="/home/aquistus/.local/bin:$PATH"

# Environment optimizations
export NO_AT_BRIDGE=1
export MOZ_ENABLE_WAYLAND=1

# Ensure DBus user session bus
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR:-/run/user/$UID}/bus"
if [ ! -S "${XDG_RUNTIME_DIR:-/run/user/$UID}/bus" ]; then
    dbus-daemon --session --address="$DBUS_SESSION_BUS_ADDRESS" --fork --nopidfile 2>/dev/null || true
fi

# Auto-start Sway on TTY1 login
if [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty 2>/dev/null)" = "/dev/tty1" ]; then
    exec sway
fi
