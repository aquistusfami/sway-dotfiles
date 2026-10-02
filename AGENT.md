# AGENT.md — Multi-OS & Multi-WM Deployment Guide

> **For AI agents:** Read this entire file before touching any config or running commands on the target machine.
> This repository houses a modular Wayland desktop environment built on the **Acid Dark** design system.
> Follow the pre-flight checklist, identify target OS and Window Manager (WM), then execute the matched deployment path.

---

## 1. Reference Machine Profile (Origin Hardware)

| Field | Baseline Value | Adaptation Requirement on Other Hardware |
|---|---|---|
| Hardware | Lenovo ThinkPad P14s Gen 5 AMD | Remove `thinkfan` and TLP ThinkPad charge thresholds if not ThinkPad |
| CPU | Ryzen 7 PRO 8840HS (Zen 4, 8C/16T) | Adjust CPU frequency/governor rules if using Intel or desktop CPU |
| GPU | AMD Radeon 780M (RADV / Mesa) | If Nvidia: configure proprietary drivers + Wayland env flags |
| Displays | eDP-1 (2880×1800@120Hz, scale 1.5) + HDMI-A-1 | Detect with `wlr-randr` / `niri msg outputs` and adjust scale/mode |
| OS | NixOS (nixos-unstable, Flakes) | If Arch/Fedora/Debian: use distro packages + `install.sh` |
| Primary WM | **Niri** (scrollable-tiling Wayland) | Also supports **Sway** natively, or port to Hyprland |
| Shell | Zsh + Starship | Fully cross-platform POSIX/Zsh |

---

## 2. Design System (Global Visual Language)

**Do not deviate from these design tokens** when editing or generating configurations across any WM.

### Colors (Acid Dark)
| Token | Hex / Value | Scope |
|---|---|---|
| Background | `#141419` (`f2` = 95% opacity) | mako, fuzzel, waybar, foot |
| Foreground / Text | `#f5f5f7` | mako, waybar, foot |
| Active Border | `#ffffff40` (25% white) | niri, sway, mako, fuzzel, waybar |
| Inactive Border | `#ffffff20` (12% white) | niri, sway |
| Yellow Accent | `#f3f99d` | waybar icons, fastfetch keys, mako low urgency |
| Pink Accent (Urgent) | `#ff6ac1` | mako critical, terminal alerts |

### Typography
| Component | Font Family | Size |
|---|---|---|
| UI / Notifications (mako) | `JetBrainsMono Nerd Font` | 10.5 pt |
| Terminal (foot) | `GeistMono Nerd Font` (fallback: `JetBrainsMono Nerd Font`) | 10.5 pt |
| Bar (waybar) | System default / `JetBrainsMono Nerd Font` | 12px, weight 500 |

### Geometry (Dual Mode)
| Property | Float Mode (Default) | Full Mode |
|---|---|---|
| Window Gaps | 4px | 0px |
| Corner Radius | 8px | 0px |
| Border Width | 1px | 1px |
| Waybar Margin | 4px | 0px |
| Fuzzel Radius | 8px | 0px |

---

## 3. Repository Architecture & Modularity

The repository separates the desktop into 4 independent tiers:

```
dotfiles/
├── AGENT.md                       ← Comprehensive deployment guide for AI agents
├── install.sh                     ← Universal symlink installer (safe, non-destructive)
├── nixos/                         ← NixOS declarative system configuration
│   ├── configuration.nix
│   └── flake.nix
├── .config/
│   ├── [TIER 1: COMPOSITORS]
│   │   ├── niri/                  ← Primary: Niri scrollable-tiling (config.kdl + scripts)
│   │   └── sway/                  ← Fallback: Sway i3-compatible tiling (config + scripts)
│   ├── [TIER 2: WAYLAND SHELL]
│   │   ├── waybar/                ← Glass capsule status bar (float / full modes)
│   │   ├── fuzzel/                ← Application launcher (Acid Dark, 8px radius)
│   │   ├── mako/                  ← Notification daemon
│   │   ├── swaylock/              ← Lockscreen config
│   │   ├── swayimg/               ← Native Wayland gallery & wallpaper picker
│   │   └── kanshi/                ← Dynamic monitor hotplugging
│   ├── [TIER 3: TERMINAL & APPS]
│   │   ├── foot/                  ← Standalone fast Wayland terminal
│   │   ├── starship.toml          ← Prompt theme
│   │   ├── fastfetch/             ← System info card
│   │   ├── btop/                  ← System monitor
│   │   ├── nnn/                   ← Terminal file manager + custom launcher
│   │   ├── nvim/                  ← LazyVim, LaTeX/SyncTeX, JDT.LS
│   │   ├── zathura/               ← PDF viewer with SyncTeX
│   │   ├── mpv/                   ← Minimal video player
│   │   └── fcitx5/                ← Vietnamese input (Bamboo)
│   └── [TIER 4: THEMES & DESKTOP]
│       ├── gtk-3.0/ & gtk-4.0/    ← GTK dark theme & cursor config
│       ├── mimeapps.list          ← Default file associations
│       └── fontconfig/            ← Font fallback priority
├── firefox/                       ← Minimal Acid Dark userChrome.css + Betterfox user.js
└── wallpapers/                    ← Wallpaper collection
```

---

## 4. Pre-Flight Inspection (AI Agent Step 0)

Before executing any install commands, run this audit snippet to detect the environment:

```bash
# 1. Detect Distribution
cat /etc/os-release | grep -E '^ID=|^ID_LIKE='

# 2. Detect GPU Vendor (AMD / Intel / Nvidia)
lspci -nnk | grep -iE 'vga|3d|display'

# 3. Detect Form Factor (Laptop vs Desktop)
hostnamectl chassis || cat /sys/class/dmi/id/chassis_type 2>/dev/null || echo "desktop"

# 4. Detect Displays and Connected Outputs
if command -v wlr-randr >/dev/null 2>&1; then wlr-randr; elif command -v xrandr >/dev/null 2>&1; then xrandr --query; fi
```

---

## 5. OS-Specific Deployment Paths

### Path 5A — NixOS
1. Clone dotfiles to `~/dotfiles`:
   ```bash
   git clone https://github.com/aquistusfami/sway-dotfiles.git ~/dotfiles
   ```
2. Generate target machine hardware configuration:
   ```bash
   nixos-generate-config --dir /tmp/nixos-gen
   cp /tmp/nixos-gen/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
   ```
3. Copy system configuration:
   ```bash
   cp ~/dotfiles/nixos/configuration.nix /etc/nixos/configuration.nix
   cp ~/dotfiles/nixos/flake.nix /etc/nixos/flake.nix
   ```
4. Adjust machine-specific fields in `/etc/nixos/configuration.nix`:
   - Change `users.users.aquistus` to the target machine username.
   - If not a ThinkPad: remove `services.thinkfan` and TLP battery thresholds.
   - If Nvidia GPU: enable `hardware.nvidia` instead of AMD Mesa defaults.
5. Rebuild and deploy symlinks:
   ```bash
   sudo nixos-rebuild switch --flake /etc/nixos#nixos
   ~/dotfiles/install.sh
   ```

### Path 5B — Arch Linux / CachyOS / Manjaro
1. Install base Wayland shell, compositors, and fonts via `pacman`:
   ```bash
   sudo pacman -S --needed \
     niri sway swaybg swayidle swaylock swayimg \
     waybar fuzzel mako foot starship fastfetch btop nnn neovim zsh \
     grim slurp wl-clipboard cliphist wlsunset kanshi \
     polkit-gnome brightnessctl pamixer networkmanager bluez bluez-utils \
     fcitx5 fcitx5-bamboo fcitx5-gtk fcitx5-qt \
     atool p7zip unrar \
     ttf-jetbrains-mono-nerd
   ```
2. Install AUR dependencies (e.g. via `yay` or `paru`):
   ```bash
   yay -S --needed ttf-geist-mono-nerd
   ```
3. Run universal symlink installer:
   ```bash
   chmod +x ~/dotfiles/install.sh && ~/dotfiles/install.sh
   ```

### Path 5C — Fedora / Nobara
1. Enable COPR for Niri and install packages:
   ```bash
   sudo dnf copr enable yalter/niri -y
   sudo dnf install -y \
     niri sway swaybg swayidle swaylock \
     waybar fuzzel mako foot starship fastfetch btop nnn neovim zsh \
     grim slurp wl-clipboard wlsunset kanshi \
     polkit-gnome brightnessctl pamixer NetworkManager bluez \
     fcitx5 fcitx5-bamboo fcitx5-gtk fcitx5-qt \
     atool p7zip unrar \
     jetbrains-mono-fonts-all
   ```
2. Install Geist Mono or JetBrainsMono Nerd Font to `~/.local/share/fonts/`.
3. Run `~/dotfiles/install.sh`.

### Path 5D — Ubuntu (24.04+) / Debian (Bookworm+)
1. Install available Wayland stack via `apt`:
   ```bash
   sudo apt update && sudo apt install -y \
     sway swaybg swayidle swaylock \
     waybar fuzzel mako-notifier foot starship btop nnn neovim zsh \
     grim slurp wl-clipboard wlsunset kanshi \
     policykit-1-gnome brightnessctl pamixer network-manager bluez \
     fcitx5 fcitx5-bamboo fonts-jetbrains-mono \
     atool p7zip-full unrar
   ```
2. For Niri on Debian/Ubuntu: download release binary from `github.com/YaLTeR/niri/releases` or build via `cargo install --locked niri`.
3. Run `~/dotfiles/install.sh`.

---

## 6. Window Manager / Compositor Selection Guide

The dotfiles repository provides pre-configured environments for multiple WMs:

### Option 6A — Niri (Default / Primary)
- **Config Path**: `~/.config/niri/config.kdl`
- **Display Setup**: Run `niri msg outputs`, then edit the `output` blocks in `config.kdl` to match connector names (e.g. `eDP-1`, `DP-1`, `HDMI-A-1`) and set proper resolution/scaling.
- **Reload**: `niri msg action reload-config`

### Option 6B — Sway (Complete Alternative in Repo)
- **Config Path**: `~/.config/sway/config`
- **Display Setup**: Run `swaymsg -t get_outputs`, then edit `output <name> resolution <res> position <pos> scale <scale>` in `~/.config/sway/config`.
- **Startup**: `sway` launches the same Waybar, Fuzzel, Mako, Foot, and Swaybg seamlessly.
- **Reload**: `swaymsg reload` (`Mod+Shift+C`)

### Option 6C — Hyprland (Porting Guide)
When the user requests Hyprland on top of these dotfiles:
1. Re-use existing Tier 2 & 3 tools without modification:
   - Status bar: Waybar (`~/.config/waybar/config.jsonc` + `style.css`)
   - Launcher: Fuzzel (`~/.config/fuzzel/fuzzel.ini`)
   - Notifications: Mako (`~/.config/mako/config`)
   - Terminal: Foot (`~/.config/foot/foot.ini`)
   - Shell & Editors: Starship, Neovim, Fastfetch, Btop
2. In `~/.config/hypr/hyprland.conf`, set matching Acid Dark theme variables:
   ```ini
   general {
       gaps_in = 2
       gaps_out = 4
       border_size = 1
       col.active_border = rgba(ffffff40)
       col.inactive_border = rgba(ffffff20)
   }
   decoration {
       rounding = 8
   }
   exec-once = waybar & mako & swaybg -i ~/.config/niri/current_wallpaper -m fill & fcitx5 -d &
   ```

### Option 6D — Desktop Environments (GNOME / KDE / X11)
When the target system runs a full desktop environment:
- `install.sh` links terminal, editor, shell, and browser configs cleanly.
- Do **not** launch Waybar, Mako, or Swaybg inside GNOME or KDE sessions.

---

## 7. Hardware & GPU Adaptation Checklist

### A. GPU Configuration
- **AMD (Radeon 780M / Navi)**: Default setup. Fully supported out of the box via Mesa `radv`.
- **Intel (Xe / Arc / UHD)**: Works out of the box with Mesa `iris`. Verify `intel-media-driver` is installed for VA-API video acceleration.
- **Nvidia (Proprietary Drivers)**:
  1. Add environment variables to `~/.zprofile` or `/etc/environment`:
     ```bash
     export LIBVA_DRIVER_NAME=nvidia
     export GBM_BACKEND=nvidia-drm
     export __GLX_VENDOR_LIBRARY_NAME=nvidia
     export NIXOS_OZONE_WL=1
     export WLR_NO_HARDWARE_CURSORS=1
     ```
  2. If running Niri with Nvidia: launch with `niri --render-drm-device /dev/dri/renderD128`.

### B. Display Scaling & Resolution
Never leave default OLED 2880×1800 scale 1.5 on non-OLED screens:
- **1080p (1920×1080)**: Set `scale 1.0` in `config.kdl` or `sway/config`.
- **1440p (2560×1440)**: Set `scale 1.0` or `scale 1.25`.
- **4K (3840×2160)**: Set `scale 1.75` or `scale 2.0`.

### C. Desktop vs Laptop Adaptation
If the machine is a **Desktop PC** (no battery, external monitors only):
1. In `~/.config/waybar/config.jsonc`, remove `"battery"` and `"backlight"` from `"modules-right"`.
2. Disable/remove `tlp` and `thinkfan` system services.

---

## 8. Cross-Platform Gotchas & Troubleshooting

| Issue | Cause | Fix |
|---|---|---|
| Binary kill fails | NixOS wraps binaries in `.name-wrapped` | Use `pkill -f <name>` (never `pkill -x`) on NixOS |
| Swaylock rejects password | Missing PAM authentication service | On NixOS: `security.pam.services.swaylock = {};`<br>On Arch/Debian: verify `/etc/pam.d/swaylock` exists |
| Icons missing in Waybar/Fastfetch | Nerd fonts not loaded | Ensure `JetBrainsMono Nerd Font` or `GeistMono Nerd Font` is installed |
| X11 apps invisible on Niri | XWayland not running | Ensure `xwayland` package installed and restart Niri session |
| Power shortcuts fail | Non-systemd or permission issue | Powermenu uses `systemctl suspend/poweroff/reboot`. Verify user in `wheel` or `power` group |

---

## 9. Key Bindings Quick Reference

`$mod` = Super (Windows Key)

| Action | Niri Binding | Sway Binding | Command Executed |
|---|---|---|---|
| Terminal | `Mod+Return` | `Mod+Return` | `foot` |
| App Launcher | `Mod+D` | `Mod+D` | `fuzzel` |
| Web Browser | `Mod+B` | `Mod+B` | `firefox` |
| File Manager | `Mod+E` | `Mod+E` | `foot -e n` (`nnn`) |
| Close Window | `Mod+Q` | `Mod+Q` | Native compositor close |
| Fullscreen | `Mod+F` | `Mod+F` | Native fullscreen toggle |
| Toggle Gaps (Float ↔ Full) | `Mod+G` | `Mod+G` | `toggle-gaps.sh` |
| Wallpaper Picker | `Mod+Shift+W` | `Mod+Shift+W` | `swayimg` gallery script |
| Power Menu | `Mod+Shift+E` | `Mod+Shift+E` | `powermenu.sh` |
| Area Screenshot | `Mod+Shift+S` | `Mod+Shift+S` | `grim -g "$(slurp)"` → wl-copy + file |
| Toggle Bar | `Mod+O` | `Mod+O` | `pkill -USR1 waybar` or hide |

---

## 10. AI Agent Operational Workflow

When modifying or deploying this repository:
1. **Run Pre-Flight Audit (Section 4)** to understand the host system before modifying files.
2. **Respect Design Tokens (Section 2)**: Never change hex colors or radiuses arbitrarily.
3. **Keep Scripts Executable**: Any new `.sh` or `.py` script must have `chmod +x`.
4. **Commit Cleanly**:
   ```bash
   git -C ~/dotfiles add -A
   git -C ~/dotfiles commit -m "feat/fix: <clear summary>"
   ```
5. **Verify live changes**:
   - Niri: `niri msg action reload-config`
   - Sway: `swaymsg reload`
   - Waybar: `pkill -f waybar && waybar &`
   - Mako: `makoctl reload`
