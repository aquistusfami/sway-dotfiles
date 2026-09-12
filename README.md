# dotfiles

Modular, minimalist Wayland desktop environment configured for NixOS and Sway WM, featuring custom terminal-based connection managers, PipeWire audio routing, hardware-accelerated Firefox styling, and low-latency development workflows. Updated: 12/09/2026

## Preview 

**Fastfetch, nnn file manager, btop and waybar.**

![alt tag](https://github.com/aquistusfami/sway-dotfiles/blob/main/preview/Screenshot_2026-09-12_07-37-28.png)

**No gap preview, nvim, fastfetch.**

![alt tag](https://github.com/aquistusfami/sway-dotfiles/blob/main/preview/Screenshot_2026-09-12_07-34-55.png)

## Overview

- **Operating System:** NixOS (Flakes, Linux 6.18+, systemd)
- **Hardware Platform:** Lenovo ThinkPad P14s Gen 5 AMD (Ryzen 7 PRO 8840HS / Radeon 780M)
- **Compositor:** Sway (Wayland i3-compatible tiling window manager)
- **Status Bar:** Waybar (modular, dual-layout support with Focus Mode / idle inhibitor)
- **Terminal Emulator:** Foot (server/client architecture via `footclient`)
- **Shell & Prompt:** Zsh (sub-100ms startup with compiled `.zwc` cache) + Starship
- **Code Editor:** Neovim (LazyVim, LaTeX/SyncTeX, Data Engineering stack)
- **Image Viewer & Gallery:** Swayimg (native Wayland image viewer & wallpaper gallery)
- **Web Browser:** Firefox (Custom Acid Dark minimal theme, Betterfox, VA-API hardware acceleration)
- **Application Launcher:** Fuzzel
- **File Transfer:** LocalSend (AirDrop cross-platform alternative)
- **Notification Daemon:** Mako
- **Document Viewer:** Zathura (minimalist PDF viewer with SyncTeX support)
- **Power & Thermal:** TLP (75-80% battery threshold) & Thinkfan active curve (~40°C target)
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

### Battery & Thermal Management (TLP & Thinkfan)
- **Battery Longevity:** ThinkPad battery charging thresholds set to stop at **80%** and resume at **75%** (`STOP_CHARGE_THRESH_BAT0=80`, `START_CHARGE_THRESH_BAT0=75`) to prolong battery lifespan.
- **Cool & Silent Operation:**
  - Disabled aggressive Turbo Boost on AC and Battery (`CPU_BOOST=0`) to eliminate unnecessary heat spikes.
  - `powersave` governor paired with `power` Energy Performance Preference (EPP).
  - Native **`thinkfan`** active cooling profile: activates whisper-quiet Level 1 (~1800 RPM) at 38°C to keep the AMD Zen 4 APU sitting comfortably at ~40°C.

### Audio & Bluetooth Routing
- Fully integrated with PipeWire 1.6+ and WirePlumber.
- Out-of-the-box support for SBC, AAC, and LDAC Bluetooth audio codecs via `libspa-bluetooth`.
- Automatic audio stream handoff to paired headsets (e.g., Sony WH-CH520) upon connection.

### Waybar Multi-Style Layouts & Focus Mode
- **Dual Layout Switcher (`toggle-style.sh`):**
  - `full`: Edge-to-edge system panel.
  - `float`: Island/pill floating bar with 5px margins and border framing.
- **Focus Mode (`idle_inhibitor`):** One-touch toggle on the left of Waybar:
  - **Active (``):** Suppresses all idle timeouts; display remains permanently awake.
  - **Inactive (``):** Standard power-saving (locks screen at 5m, powers display off at 5.5m, suspends system at 10m).

### Visual Wallpaper Gallery (Swayimg)
- Native Wayland gallery picker (`swayimg`) spawned centered on the active monitor.
- Instant 250px thumbnail grid browsing via arrow keys or mouse hover.
- Interactive scaling mode switcher (`m` or `Tab` cycles: `fill` ⇄ `fit` ⇄ `stretch` ⇄ `center` ⇄ `tile`).
- One-click or `Enter` to apply and persist across sessions.

## Keybindings

Default modifier (`$mod`) is `Super` (Windows key).

### Application Shortcuts
| Keybinding | Target | Description |
| :--- | :--- | :--- |
| `$mod + Return` | `footclient` | Spawn instant terminal instance (<30ms via daemon) |
| `$mod + d` | `fuzzel` | Application launcher |
| `$mod + b` | `firefox` | Web browser |
| `$mod + e` | `nnn` | Terminal file manager (with native `swayimg` viewer) |
| `$mod + Shift + w` | `wallpaper-picker.sh` | Visual wallpaper gallery picker & mode switcher |

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

## Package Requirements (NixOS)

Under NixOS, all packages and system daemons are managed declaratively via `/etc/nixos/configuration.nix` and Flakes:

```nix
environment.systemPackages = with pkgs; [
  # Compositor & Wayland Utilities
  sway waybar foot fuzzel mako swaylock swayimg
  brightnessctl grim slurp wl-clipboard jq yq

  # Shell, Prompt & Monitoring
  zsh starship fastfetch btop nnn

  # Media, Docs & Code
  neovim zathura mpv
];

# Hardware Services
services.tlp.enable = true;
services.thinkfan.enable = true;
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
│   ├── nvim/           # Neovim (LazyVim, TeX/SyncTeX, Data Engineering)
│   ├── starship.toml   # Cross-shell prompt configuration
│   ├── sway/           # Sway rules, keybinds, and visual wallpaper picker
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
