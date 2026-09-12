# Geist Sans × JetBrains Mono Typography Design

## 1. Overview & Problem Statement
Currently, `JetBrainsMono Nerd Font` (or its Propo variant) is enforced globally across all UI elements (status bars, dialogs, application launchers, window titles). Monospace fonts—even with proportional spacing modifications—lack the optical kerning, varied stroke weights, and natural rhythm of a dedicated Neo-Grotesque sans-serif UI font. This results in stretched button labels, awkward table alignment in file pickers, and visual fatigue.

## 2. Goals
- Establish a clean, modern dual-font system pairing **Geist Sans** (UI) and **JetBrainsMono Nerd Font** (Code/Icons).
- Provide optimal legibility and visual harmony with the existing **Acid Dark** color scheme.
- Maintain full Nerd Font icon coverage across Sway, Waybar, Fuzzel, and Mako without broken glyphs.

## 3. Font Role Allocation
1. **UI / Shell / Dialogs / Menus / Status Bar (`Geist`)**:
   - High-density screen optimization designed by Vercel.
   - Clean geometric grotesque curves, sharp definition on HiDPI screens.
   - Target sizes: 10.5pt – 11pt.
2. **Code / Terminal / Neovim / Nerd Icons (`JetBrainsMono Nerd Font`)**:
   - Preserves coding legibility, ligatures, and monospace character cell alignment.
   - Supplies all Nerd Font glyphs (`󰈚`, ``, ``, `󰐥`) as fallback for Waybar and Fuzzel.

## 4. Component Changes
- **NixOS (`/etc/nixos/configuration.nix`)**: Add `geist-font` to `fonts.packages`.
- **Fontconfig (`~/.config/fontconfig/fonts.conf`)**:
  - Prepend `Geist` to `sans-serif`.
  - Maintain `JetBrainsMono Nerd Font` as default `monospace`.
- **GTK 3 & 4 (`~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-4.0/settings.ini`)**:
  - `gtk-font-name=Geist 11`
  - `gtk-xft-dpi=98304`
- **GSettings / dconf (`org.gnome.desktop.interface`)**:
  - `font-name='Geist 11'`
  - `document-font-name='Geist 11'`
  - `monospace-font-name='JetBrainsMono Nerd Font 10.5'`
- **Waybar (`~/.config/waybar/style*.css`)**:
  - Set `font-family: "Geist", "JetBrainsMono Nerd Font", "Font Awesome 6 Free", sans-serif;`
- **Fuzzel (`~/.config/fuzzel/fuzzel.ini`)**:
  - `font=Geist:size=11`
- **Mako (`~/.config/mako/config`)**:
  - `font=Geist 10.5`
- **Sway (`~/.config/sway/config`)**:
  - `font pango:Geist, JetBrainsMono Nerd Font 10`
- **Foot Terminal (`~/.config/foot/foot.ini`)**:
  - Unchanged (`JetBrainsMono Nerd Font:size=10.5`).

## 5. Verification Plan
- `nixos-rebuild dry-build` or `nix flake check` / rebuild switch to activate `geist-font`.
- `fc-match sans-serif` verifies `Geist-Regular.otf` resolves as default UI font.
- Reload Sway, Waybar, and restart `xdg-desktop-portal-gtk`.
- Take screenshot of file chooser dialog and Waybar to verify glyph alignment and crisp rendering.
