# dotfiles

Modular, minimalist Wayland desktop environment configured for Void Linux and Sway WM, featuring custom terminal-based connection managers, PipeWire audio routing, and low-latency workflows. Updated: 07/09/2026

## Overview

- **Operating System:** Void Linux (glibc, runit)
- **Compositor:** Sway (Wayland i3-compatible tiling window manager)
- **Status Bar:** Waybar (modular, multi-layout support)
- **Terminal Emulator:** Foot (server/client architecture)
- **Shell & Prompt:** Zsh with Starship
- **Application Launcher:** Fuzzel
- **Notification Daemon:** Mako
- **Audio Stack:** PipeWire, WirePlumber, PipeWire-Pulse (`libspa-bluetooth`)
- **Input Method:** Fcitx5 (Bamboo Vietnamese engine)
- **Color Palette:** Acid Dark

## System Architecture & Features

### Lightweight Network & Bluetooth Managers
Instead of running heavy GTK/Electron background applets (e.g., `blueman-applet`, `nm-applet`), the environment utilizes custom curses-based TUI utilities launched on-demand in floating terminal windows:
- **Zero Idle Memory:** No daemon running in the background; processes terminate cleanly upon exit.
- **Continuous Real-Time Discovery:** Live scan loop with automatic signal refresh and timeout-based pruning of offline nodes.
- **Interactive Controls:**
  - One-touch connect/disconnect via keyboard or mouse.
  - In-terminal password prompt for encrypted access points.
  - Dedicated shortcuts for captive portal authentication (`neverssl.com`), network forget, and manual rescan.
- **Waybar Bindings:**
  - `Left-Click`: Launch floating TUI manager (`termfloat`).
  - `Right-Click`: Hardware radio toggle (`rfkill toggle wifi` / `rfkill toggle bluetooth`).
  - `Hover Tooltip`: Display IP address, interface, gateway, or connected device battery state.

### Audio & Bluetooth Routing
- Fully integrated with PipeWire 1.6+ and WirePlumber.
- Out-of-the-box support for SBC, AAC, and LDAC Bluetooth audio codecs via `libspa-bluetooth`.
- Automatic audio stream handoff to paired headsets (e.g., Sony WH-CH520) upon connection.

### Waybar Multi-Style Layouts
- Dual style switching (`toggle-style.sh`):
  - `full`: Edge-to-edge system panel.
  - `float`: Island/pill floating bar with rounded borders.

## Keybindings

Default modifier (`$mod`) is `Super` (Windows key).

### Application Shortcuts
| Keybinding | Target | Description |
| :--- | :--- | :--- |
| `$mod + Return` | `foot` | Spawn new terminal instance |
| `$mod + d` | `fuzzel` | Application launcher |
| `$mod + b` | `firefox` | Web browser |
| `$mod + e` | `nnn` | Terminal file manager |
| `$mod + w` | `wallpaper-picker.sh` | Interactive wallpaper selection menu |

### Window Management
| Keybinding | Action |
| :--- | :--- |
| `$mod + q` | Close focused window |
| `$mod + Shift + q` | Force terminate process (`kill -9`) |
| `$mod + f` | Toggle fullscreen |
| `$mod + Space` | Toggle floating mode |
| `$mod + g` | Toggle window gaps |
| `$mod + Arrow / h,j,k,l` | Change focus |
| `$mod + Shift + Arrow / h,j,k,l` | Move window |

### System & Utilities
| Keybinding | Action |
| :--- | :--- |
| `$mod + Shift + s` | Interactive area screenshot (copied to clipboard and saved to disk) |
| `$mod + Print` | Capture full screen |
| `$mod + o` | Toggle Waybar visibility |
| `$mod + Shift + e` | Powermenu (Lock, Logout, Suspend, Reboot, Shutdown) |
| `$mod + Shift + c` | Reload Sway configuration |

## Installation

### 1. Clone Repository
```bash
git clone https://github.com/<username>/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Deploy Symbolic Links
The `install.sh` script creates non-destructive symbolic links from `~/dotfiles` to `~/.config` and `~/`. Existing files are backed up with a `.backup` suffix.

```bash
chmod +x install.sh
./install.sh
```

## Package Requirements (Void Linux)

Install core desktop components:

```bash
sudo xbps-install -S \
    sway \
    waybar \
    foot \
    fuzzel \
    mako \
    swaylock \
    starship \
    zsh \
    btop \
    pipewire \
    wireplumber \
    libspa-bluetooth \
    NetworkManager \
    bluez \
    brightnessctl \
    grim \
    slurp \
    wl-clipboard \
    jq
```

## Directory Structure

```text
dotfiles/
├── .config/
│   ├── btop/           # System monitor configuration
│   ├── fcitx5/         # Input method settings
│   ├── fontconfig/     # Font rendering and fallback rules
│   ├── foot/           # Terminal emulator styling and keybinds
│   ├── fuzzel/         # Application launcher configuration
│   ├── mako/           # Notification styles
│   ├── nnn/            # Terminal file manager integration
│   ├── starship.toml   # Cross-shell prompt configuration
│   ├── sway/           # Sway compositor rules, keybindings, and scripts
│   ├── swaylock/       # Screen lock styling
│   └── waybar/         # Status bar configurations, stylesheets, and TUI scripts
├── wallpapers/         # Desktop background collection
├── .bash_profile
├── .bashrc
├── .zprofile
├── .zshrc
├── .gitignore
├── install.sh          # Deployment script
└── README.md
```

## License

This configuration is released under the MIT License.
