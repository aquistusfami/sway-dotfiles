# Design Document: Waybar Hover Tooltips Refinement

## Context
Waybar modules currently display hover tooltips with an outdated styling: 4px rounded borders, yellow (`@warning`) accent colors, and unformatted technical output (e.g. 16 raw CPU cores, plain text calendar). This clashes with the system's Acid Dark theme (flat, 0px border-radius, `#181818` background, `#333333` subtle borders, Geist & JetBrains Mono typography).

## Scope & Requirements
1. **Visual Styling**:
   - `border-radius: 0px` across all tooltip popups.
   - Background: flat `#181818` (or `rgba(24, 24, 24, 0.98)`).
   - Border: `1px solid #333333`.
   - Box shadow: `none`.
   - Padding: `8px 12px`.
   - Tooltip text: `#eff0eb` (clean off-white), font `Geist` with `JetBrainsMono Nerd Font` fallback.

2. **Calendar Formatting (Clock Module)**:
   - Calendar popup formatted using Waybar's native calendar markup:
     - Month header: Cyan (`#57c7ff`) bold.
     - Weekday headers: Muted gray (`#929292`).
     - Regular days: Off-white (`#eff0eb`) in monospace.
     - Current day (`today`): Acid Green background (`#5af78e`) with dark text (`#181818`).
   - Monospace wrapping (`<tt>`) ensures calendar columns align horizontally.

3. **Module-specific Tooltip Content**:
   - **CPU**: Clean summary `CPU: {usage}%\nLoad: {load}` (replacing multi-line individual cores).
   - **Memory**: Clear RAM & Swap metrics `RAM: {used:0.1f}GB / {total:0.1f}GB ({percentage}%)\nSwap: {swap_used:0.1f}GB / {swap_total:0.1f}GB`.
   - **Battery**: Concise status `Pin: {capacity}%\nThời gian còn lại: {time}\nTrạng thái: {status}`.
   - **Pulseaudio & Backlight**: Enable clean tooltips displaying volume / brightness and active port/sink.
   - **Network & Bluetooth**: Retain detailed info formatted cleanly.

4. **Multi-mode Synchronization**:
   - Mirror configuration and CSS across both Float mode (`config-float.jsonc`, `style-float.css`) and Full mode (`config-full.jsonc`, `style-full.css`), plus active files (`config.jsonc`, `style.css`), both in `~/.config/waybar/` and `~/dotfiles/.config/waybar/`.
