# dotfiles

Modular, minimalist Wayland desktop environment configured for Void Linux and Sway WM, featuring custom terminal-based connection managers, PipeWire audio routing, hardware-accelerated Firefox styling, and low-latency development workflows. Updated: 08/09/2026

## Preview 

**Fastfetch, nnn file manager and waybar.**

![alt tag](https://github.com/aquistusfami/sway-dotfiles/blob/main/preview/Screenshot_2026-09-08_07-59-35.png)

**No gap preview, nvim, btop.**

![alt tag](https://github.com/aquistusfami/sway-dotfiles/blob/main/preview/Screenshot_2026-09-08_08-08-52.png)

## Overview

- **Operating System:** Void Linux (glibc, runit)
- **Compositor:** Sway (Wayland i3-compatible tiling window manager)
- **Status Bar:** Waybar (modular, multi-layout support with 5px margins)
- **Terminal Emulator:** Foot (server/client architecture)
- **Shell & Prompt:** Zsh with Starship
- **Code Editor:** Neovim (LazyVim, JDT.LS for Java OOP, Tectonic/Zathura SyncTeX)
- **Web Browser:** Firefox (Custom Acid Dark minimal theme, Betterfox, VA-API hardware acceleration)
- **Application Launcher:** Fuzzel
- **File Transfer:** LocalSend (AirDrop cross-platform alternative)
- **Notification Daemon:** Mako
- **Document Viewer:** Zathura (minimalist PDF viewer with SyncTeX support)
- **Power & Thermal:** TLP (ASUS battery health 90% charge threshold, silent fan, turbo-boost throttling)
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

### Firefox Minimal Acid Dark Suite
Customized Firefox profile tailored specifically for Sway and the Acid Dark aesthetic:
- **`userChrome.css`**:
  - Hidden window controls & titlebar spacers (handled by Sway).
  - Compact 28px flat tabs with 0px border radius and 2px accent top border for focused tab.
  - Centered, minimalist URL bar with JetBrains Mono typography.
  - Flat context menus, panels, and scrollbars.
- **`user.js`**:
  - Hardened privacy and speed optimizations via **Betterfox**.
  - Enforced VA-API hardware video decoding (`iHD` driver).
  - Disabled AV1 software decoding fallback (`media.av1.enabled: false`) to guarantee VP9/H.264 GPU decoding with minimal CPU usage.

### Development Environment (Neovim / LazyVim)
- **Java OOP Workflow:** Configured with Eclipse JDT.LS, automatic OOP generation (getters/setters, constructors, interfaces), and memory-capped JVM limits (`-Xmx512m`).
- **LaTeX & Documentation:** Integrated with Tectonic compiler and Zathura PDF viewer featuring bidirectional SyncTeX synchronization.
- **File Navigation:** Customized `nnn` terminal file manager wrapper (`n`) with POSIX fallback (`mv`/`cp`), cd-on-quit, and custom file opener script.

### Battery & Thermal Management (TLP)
- **Battery Longevity:** ASUS Battery Health Charging threshold set to stop charging at **90%** (`STOP_CHARGE_THRESH_BAT0=90`) to prolong battery lifecycle.
- **Cool & Silent Operation:**
  - Disabled aggressive Turbo Boost on AC and Battery (`CPU_BOOST=0`) to prevent temperature spikes over 45°C and eliminate fan noise.
  - `powersave` governor paired with `balance_power` / `power` Energy Performance Preference (EPP).

### Audio & Bluetooth Routing
- Fully integrated with PipeWire 1.6+ and WirePlumber.
- Out-of-the-box support for SBC, AAC, and LDAC Bluetooth audio codecs via `libspa-bluetooth`.
- Automatic audio stream handoff to paired headsets (e.g., Sony WH-CH520) upon connection.

### Waybar Multi-Style Layouts
- Dual style switching (`toggle-style.sh`):
  - `full`: Edge-to-edge system panel.
  - `float`: Island/pill floating bar with 5px margins and border framing.

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
git clone https://github.com/aquistusfami/sway-dotfiles.git ~/dotfiles
cd ~/dotfiles
```

### 2. Deploy Symbolic Links
The `install.sh` script creates non-destructive symbolic links from `~/dotfiles` to `~/.config`, `~/.local`, and `~/`. Existing files are backed up with a `.backup` suffix.

```bash
chmod +x install.sh
./install.sh
```

## Package Requirements (Void Linux)

Install core desktop and productivity packages:

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
    nnn \
    neovim \
    zathura \
    zathura-pdf-mupdf \
    fastfetch \
    tlp \
    intel-media-driver \
    libva-utils \
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
│   ├── fastfetch/      # Minimal system information layout
│   ├── fcitx5/         # Input method settings
│   ├── fontconfig/     # Font rendering and fallback rules
│   ├── foot/           # Terminal emulator styling and keybinds
│   ├── fuzzel/         # Application launcher configuration
│   ├── mako/           # Notification styles
│   ├── nnn/            # Terminal file manager integration & scripts
│   ├── nvim/           # Neovim (LazyVim, Java OOP, TeX/SyncTeX)
│   ├── starship.toml   # Cross-shell prompt configuration
│   ├── sway/           # Sway compositor rules, keybindings, and scripts
│   ├── swaylock/       # Screen lock styling
│   ├── waybar/         # Status bar configurations, stylesheets, and TUI scripts
│   └── zathura/        # Minimalist PDF viewer configuration
├── .local/
│   └── share/
│       ├── applications/ # Custom desktop entries (nnn, localsend)
│       └── icons/        # High-resolution application logos
├── firefox/            # Firefox customizations
│   ├── chrome/         # Minimal Acid Dark userChrome.css & userContent.css
│   └── user.js         # Betterfox performance & VA-API video settings
├── system/
│   └── tlp/            # Hardware battery threshold & CPU thermal profile
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
