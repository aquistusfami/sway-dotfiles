# AGENT.md — Machine Deployment Guide

> **For AI agents:** Read this entire file before touching any config.
> Everything you need to replicate this setup on a new machine is here.
> Follow the steps in order. Do not skip sections.

---

## 1. Machine Profile

| Field | Value |
|---|---|
| Hardware | Lenovo ThinkPad P14s Gen 5 AMD |
| CPU | Ryzen 7 PRO 8840HS (Zen 4, 8C/16T) |
| GPU | AMD Radeon 780M (integrated, VA-API capable) |
| RAM | 27.1 GB |
| Display 1 | eDP-1 — 2880×1800 OLED 120Hz, scale 1.5 |
| Display 2 | HDMI-A-1 — 2560×1440 60Hz, scale 1.25 |
| OS | NixOS (nixos-unstable channel) |
| Compositor | **Niri** (scrollable-tiling Wayland) |
| Shell | Zsh + Starship |
| Username | `aquistus` |
| Timezone | `Asia/Ho_Chi_Minh` |
| Locale | `en_US.UTF-8` (LC_* set to `vi_VN`) |

**If deploying to different hardware**, you MUST:
- Generate new `hardware-configuration.nix` via `nixos-generate-config`
- Adjust display outputs in `.config/niri/config.kdl` (output names, mode, scale)
- Remove ThinkPad-specific services (thinkfan, TLP thresholds) if not ThinkPad

---

## 2. Design System (Global Visual Language)

All configs follow a single coherent aesthetic. **Do not deviate from these values** when editing any config file.

### Colors
| Token | Value | Used in |
|---|---|---|
| Background | `#141419` (`f2` opacity = 95%) | mako, fuzzel, waybar |
| Text | `#f5f5f7` | mako, waybar, foot |
| Border (active) | `#ffffff40` (25% white) | niri windows, mako, fuzzel, waybar |
| Border (inactive) | `#ffffff20` (12% white) | niri windows |
| Icon accent (yellow) | `#f3f99d` | waybar icons, fastfetch keys |
| Error / urgent | `#ff6ac1` (pink) | mako critical, terminal |
| Warning | `#f3f99d` (same yellow) | mako low urgency |

### Typography
| Usage | Font | Size |
|---|---|---|
| UI / Notifications (mako) | `JetBrainsMono Nerd Font` | 10.5 |
| Terminal (foot) | `GeistMono Nerd Font` | 10.5 |
| Waybar | System default | 12px, weight 500 |

### Geometry
| Property | Float mode | Full mode |
|---|---|---|
| Window gaps | 4px | 0px |
| Corner radius | 8px | 0px |
| Niri border-width | 1px | 1px |
| Waybar margin | 4px | 0px |
| Fuzzel border-radius | 8px | 0px |

---

## 3. Repository Layout

```
dotfiles/
├── AGENT.md                    ← you are here
├── README.md                   ← human-readable overview
├── install.sh                  ← symlink deployment script
├── nixos/
│   ├── configuration.nix       ← full NixOS system config (copy to /etc/nixos/)
│   └── flake.nix               ← flake with nixos-hardware module
├── .config/
│   ├── niri/
│   │   ├── config.kdl          ← compositor: inputs, outputs, keybinds, layout
│   │   ├── current_wallpaper   ← symlink → active wallpaper (set by wallpaper-picker)
│   │   └── scripts/
│   │       ├── wallpaper-picker.lua  ← swayimg gallery → sets current_wallpaper
│   │       ├── toggle-gaps.sh        ← Mod+G: switch float ↔ full mode
│   │       └── powermenu.sh          ← Mod+Shift+E: lock/logout/suspend/reboot/shutdown
│   ├── waybar/
│   │   ├── config.jsonc        ← bar modules, positions, bindings
│   │   ├── style.css           ← glass capsule design, colors, animations
│   │   ├── wifi-menu.sh        ← wifi TUI manager (nmcli + curses)
│   │   ├── bluetooth-menu.sh   ← bluetooth TUI manager (bluetoothctl + curses)
│   │   └── wifi-scanner.py     ← background wifi scan for waybar tooltip
│   ├── foot/foot.ini           ← terminal: GeistMono, Acid Dark colors, keybinds
│   ├── fuzzel/fuzzel.ini       ← launcher: glass theme, foot terminal, radius 8
│   ├── mako/config             ← notifications: JetBrainsMono, glass, 8px radius
│   ├── swaylock/config         ← lock screen: wallpaper from niri/current_wallpaper
│   ├── fastfetch/config.jsonc  ← system info: yellow keys, nixos_medium logo
│   ├── btop/                   ← system monitor
│   ├── nvim/                   ← LazyVim, JDT.LS, Tectonic/Zathura SyncTeX
│   ├── nnn/                    ← file manager wrapper scripts
│   └── starship.toml           ← shell prompt
├── firefox/
│   ├── user.js                 ← Betterfox + VA-API + OLED color management
│   └── chrome/
│       ├── userChrome.css      ← minimal tabs, no titlebar, JetBrains Mono URL bar
│       └── userContent.css
├── wallpapers/                 ← wallpaper collection
└── system/
    └── tlp/                    ← TLP battery + thermal config (ThinkPad only)
```

---

## 4. Full Deployment Steps (New Machine)

### Step 1 — Install NixOS base
Boot NixOS installer, partition disk, then:
```bash
nixos-generate-config --root /mnt
```

### Step 2 — Deploy NixOS system config
```bash
git clone https://github.com/aquistusfami/sway-dotfiles.git ~/dotfiles

# Copy NixOS config (keep the hardware-configuration.nix generated in Step 1)
cp ~/dotfiles/nixos/configuration.nix /etc/nixos/configuration.nix
cp ~/dotfiles/nixos/flake.nix /etc/nixos/flake.nix

# IMPORTANT: Edit these in configuration.nix for the new machine:
# - users.users."aquistus" → change username if needed
# - time.timeZone → change if not Vietnam
# - services.thinkfan → remove if not ThinkPad
# - system.stateVersion → match nixos-generate-config output

sudo nixos-rebuild switch --flake /etc/nixos#nixos
```

### Step 3 — Deploy dotfiles (symlinks)
```bash
chmod +x ~/dotfiles/install.sh
~/dotfiles/install.sh
```

### Step 4 — Adjust display outputs in Niri config
Edit `~/.config/niri/config.kdl`. Find the `// --- MONITORS ---` section.
Check your output names first:
```bash
niri msg outputs
```
Update output names, modes, and scales to match your hardware.

### Step 5 — Set initial wallpaper
```bash
swaybg -i ~/Pictures/wallpapers/<any>.jpg -m fill &
```
Or use the wallpaper picker: `Mod+Shift+W` inside Niri.

### Step 6 — Firefox profile
Run Firefox once to create a profile, then `install.sh` will auto-link
`userChrome.css`, `userContent.css`, and `user.js` to the profile.
If running after Firefox was already opened:
```bash
~/dotfiles/install.sh  # re-run, it handles existing profiles
```
Enable `toolkit.legacyUserProfileCustomizations.stylesheets` in `about:config`.

---

## 5. Key Bindings (Niri)

`$mod` = Super (Windows key)

| Binding | Action |
|---|---|
| `Mod+Return` | Terminal (foot) |
| `Mod+D` | App launcher (fuzzel) |
| `Mod+B` | Firefox |
| `Mod+E` | File manager (nnn in foot) |
| `Mod+Q` | Close window |
| `Mod+F` | Fullscreen |
| `Mod+G` | Toggle float ↔ full mode (gaps + radius) |
| `Mod+Shift+W` | Wallpaper picker (swayimg gallery) |
| `Mod+Shift+E` | Power menu (lock/logout/suspend/reboot/shutdown) |
| `Mod+Shift+S` | Area screenshot → clipboard + `~/Pictures/` |
| `Mod+O` | Toggle waybar visibility |
| `Mod+←→` | Move focus left/right in workspace |
| `Mod+Shift+←→` | Move window left/right |
| `Ctrl+Alt+←→` | Switch workspace |
| `Mod+1-9` | Switch to workspace N |

---

## 6. NixOS-Specific Gotchas

These are known issues that will break things if you don't know about them.

### Process names are wrapped
NixOS wraps binaries. Always use `pkill -f` (not `-x`):
```bash
pkill -f swaybg      # correct (kills .swaybg-wrapped)
pkill -x swaybg      # WRONG — will not kill NixOS-wrapped binary
```
Affects: `swaybg`, `waybar`, `mako`, `swaylock`.

### Power management — systemctl only
On NixOS with systemd, always use:
```bash
systemctl suspend        # suspend
systemctl poweroff       # shutdown
systemctl reboot         # reboot
loginctl terminate-session $XDG_SESSION_ID  # logout
```
Do NOT use `zzz`, `pm-suspend`, or `loginctl` with trailing arguments.
The powermenu script (`powermenu.sh`) already uses correct commands.

### Swaylock authentication
PAM config is enabled in `configuration.nix`:
```nix
security.pam.services.swaylock = {};
```
Without this, swaylock will never accept the password.

### Icon paths (notification icons)
Papirus icons are NOT installed. Valid icon paths:
- `/home/aquistus/.local/share/icons/YAMIS/` (custom, from this dotfiles)
- `/run/current-system/sw/share/icons/Adwaita/`
- `/run/current-system/sw/share/icons/hicolor/`

### Niri IPC — no swaymsg
Niri does not use `swaymsg`. Use:
```bash
niri msg action <action>       # send actions
niri msg outputs               # list outputs
niri msg workspaces            # list workspaces
```

### Toggle-gaps mode state
Mode (float/full) is stored in:
```
$XDG_RUNTIME_DIR/desktop_mode_state   # contains "full" or "float"
```
`toggle-gaps.sh` patches `config.kdl`, `style.css`, and `fuzzel.ini` via `sed -i`.
After patching niri config, it reloads niri: `niri msg action reload-config`.

### Foot terminal — standalone only
`footclient` was removed. Use `foot` directly everywhere.
There is NO foot server daemon in autostart. Each `foot` call spawns its own process.

### Wallpaper persistence
`current_wallpaper` is a symlink at `~/.config/niri/current_wallpaper`.
`wallpaper-picker.lua` updates it on selection.
`swaylock/config` reads from this path for the lock screen image.

### X11 apps (OnlyOffice, etc.) require XWayland managed by Niri
`programs.xwayland.enable = true` is set in `configuration.nix`.
After `nixos-rebuild switch`, **logout and log back into Niri** — Niri will then
manage XWayland automatically and X11 apps work normally from Mod+D.

Do NOT launch `Xwayland` manually as a standalone process — it will not integrate
with Niri's compositor and windows will be invisible.

The wrapper script `.config/niri/scripts/onlyoffice.sh` exists as a fallback but
is only needed if XWayland is not being managed by Niri (i.e., before rebuild).

---

## 7. Services Running at Niri Startup

Defined in `config.kdl` under `spawn-at-startup`:

| Service | Command | Purpose |
|---|---|---|
| Waybar | `waybar` | Status bar |
| Mako | `mako` | Notifications |
| Swaybg | `swaybg -i ~/.config/niri/current_wallpaper -m fill` | Wallpaper |
| Swayidle | `swayidle -w ...` | Lock after 5min idle |
| Fcitx5 | `fcitx5 -d` | Vietnamese input (Bamboo) |
| Polkit | `polkit-gnome-authentication-agent-1` | Auth dialogs |
| Wlsunset | `wlsunset -l 10.8 -L 106.6` | Night light (Ho Chi Minh City) |
| Cliphist | `wl-paste --watch cliphist store` | Clipboard history |
| Kanshi | `kanshi` | Auto display profile switching |

---

## 8. Toggle-Gaps Behavior (Mod+G)

The `toggle-gaps.sh` script patches 3 files simultaneously:

| File | Float mode | Full mode |
|---|---|---|
| `niri/config.kdl` | `gaps 4`, `geometry-corner-radius 8` | `gaps 0`, `geometry-corner-radius 0` |
| `waybar/style.css` | `margin: 4px` on `.bar` | `margin: 0px` |
| `fuzzel/fuzzel.ini` | `border.radius=8` | `border.radius=0` |

After patching: `niri msg action reload-config` + `pkill -f waybar && waybar &`

---

## 9. Editing Workflow

When an AI agent needs to change a config:

1. **Check design tokens** (Section 2) before changing colors, fonts, or geometry.
2. **Check gotchas** (Section 6) before writing any shell command.
3. After editing dotfiles: `git -C ~/dotfiles add -A && git -C ~/dotfiles commit -m "..."`
4. Changes take effect immediately since `~/.config/*` → `~/dotfiles/.config/*` are symlinks.
5. For niri config changes: `niri msg action reload-config`
6. For waybar changes: `pkill -f waybar && waybar &`
7. For mako changes: `makoctl reload`
