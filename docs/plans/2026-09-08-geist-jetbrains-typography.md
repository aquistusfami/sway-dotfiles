# Geist Sans × JetBrains Mono Typography Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish a balanced, harmonious desktop typography pairing Geist Sans for UI elements and JetBrainsMono Nerd Font for terminal, code, and glyphs.

**Architecture:** Install `geist-font` system-wide on NixOS, configure fontconfig to map `sans-serif` to Geist with Nerd Font icon fallback, and update all desktop UI components (GTK, dconf, Waybar, Fuzzel, Mako, Sway) to use Geist while preserving JetBrains Mono for Foot, Neovim, and icons.

**Tech Stack:** NixOS, fontconfig, GTK 3/4, dconf, Sway, Waybar, Fuzzel, Mako.

## Global Constraints
- Do not modify Foot terminal font (`JetBrainsMono Nerd Font:size=10.5`).
- Ensure all icons (Font Awesome, Nerd Font glyphs) continue rendering via fallback.
- Keep GTK scaling integer 1 on Wayland (`gtk-xft-dpi=98304`).

---

### Task 1: Add `geist-font` to NixOS Configuration
**Files:**
- Modify: `/etc/nixos/configuration.nix:197-203`

- [ ] **Step 1: Edit `/etc/nixos/configuration.nix`**
  Add `geist-font` into `fonts.packages = with pkgs; [...]`.
- [ ] **Step 2: Validate NixOS configuration**
  Run `sudo nixos-rebuild test` or `nix flake check /etc/nixos`.
- [ ] **Step 3: Switch or link font package into font cache**
  Run `fc-cache -f` and verify `fc-list : family | grep -i geist`.

---

### Task 2: Configure Fontconfig Default Sans-serif
**Files:**
- Modify: `~/.config/fontconfig/fonts.conf:12-21`

- [ ] **Step 1: Update `fonts.conf` sans-serif match**
  Prepend `Geist` before `JetBrainsMono Nerd Font Propo` and `Noto Sans`.
- [ ] **Step 2: Verify with `fc-match`**
  Run `fc-match sans-serif` and confirm it resolves to `Geist-Regular.otf`.

---

### Task 3: Update GTK 3/4 and dconf Settings
**Files:**
- Modify: `~/.config/gtk-3.0/settings.ini`
- Modify: `~/.config/gtk-4.0/settings.ini`
- Shell: `dconf write /org/gnome/desktop/interface/...`

- [ ] **Step 1: Set GTK font name**
  Set `gtk-font-name=Geist 11` in both GTK 3 and GTK 4 `settings.ini`.
- [ ] **Step 2: Update dconf keys**
  Set `font-name='Geist 11'` and `document-font-name='Geist 11'`.
- [ ] **Step 3: Restart portal**
  Run `systemctl --user restart xdg-desktop-portal-gtk`.

---

### Task 4: Update Desktop Shell Components (Waybar, Fuzzel, Mako, Sway)
**Files:**
- Modify: `~/.config/waybar/style.css`, `style-float.css`, `style-full.css`
- Modify: `~/.config/fuzzel/fuzzel.ini`
- Modify: `~/.config/mako/config`
- Modify: `~/.config/sway/config`

- [ ] **Step 1: Update Waybar CSS stylesheets**
  Prepend `"Geist"` to `font-family` ahead of `"JetBrainsMono Nerd Font"`.
- [ ] **Step 2: Update Fuzzel config**
  Set `font=Geist:size=11`.
- [ ] **Step 3: Update Mako config**
  Set `font=Geist 10.5`.
- [ ] **Step 4: Update Sway window title font**
  Set `font pango:Geist, JetBrainsMono Nerd Font 10`.

---

### Task 5: Verification & Screenshot Inspection
**Files:**
- Test Output: `~/.gemini/antigravity-cli/brain/4c60adfb-0997-4e0d-bbbd-658b329a1586/scratch/geist_portal_test.png`

- [ ] **Step 1: Reload Sway and Waybar**
  Run `swaymsg reload` and kill -USR2 waybar.
- [ ] **Step 2: Trigger test file chooser dialog**
  Invoke `org.freedesktop.portal.FileChooser.OpenFile` via `busctl`.
- [ ] **Step 3: Capture screenshot with `grim` and verify**
  Confirm crisp typography, proper kerning, and intact icons.
