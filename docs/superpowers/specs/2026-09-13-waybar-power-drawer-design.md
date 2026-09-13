# Waybar Power Menu Drawer Design Spec

## Overview
Replace the single static power icon and fuzzel popup with a native Waybar sliding drawer (`group/power`). On hover, the power button smoothly expands horizontally to the left, revealing clean Font Awesome 6 icons for quick system actions matching the Acid Dark theme.

## Visual Layout
- **Collapsed**: `[  ]`
- **Expanded (on hover)**: `[  ]  [  ]  [  ]  [  ]  [  ]`

## Components & Modules

### 1. Waybar Group Drawer (`group/power`)
Configured across `config.jsonc`, `config-full.jsonc`, and `config-float.jsonc`:
```jsonc
"group/power": {
    "orientation": "inherit",
    "drawer": {
        "transition-duration": 300,
        "children-class": "drawer-child",
        "transition-left-to-right": false
    },
    "modules": [
        "custom/power",
        "custom/reboot",
        "custom/suspend",
        "custom/lock",
        "custom/quit"
    ]
}
```

### 2. Action Modules
- `custom/power`: Leader trigger. Format: `` (fa-power-off). Tooltip: `Shutdown`. On-click: `systemctl poweroff`.
- `custom/reboot`: Format: `` (fa-redo). Tooltip: `Reboot`. On-click: `systemctl reboot`.
- `custom/suspend`: Format: `` (fa-moon). Tooltip: `Suspend`. On-click: `swaylock -f && systemctl suspend`.
- `custom/lock`: Format: `` (fa-lock). Tooltip: `Lock Screen`. On-click: `swaylock -f`.
- `custom/quit`: Format: `` (fa-sign-out-alt). Tooltip: `Logout`. On-click: `swaymsg exit`.

### 3. CSS Styling (Acid Dark Theme)
Applied across `style.css`, `style-float.css`, and `style-full.css`:
- Border-radius: `0px` (strict flat aesthetic).
- Bottom border: `2px solid <color>` per action matching Waybar status modules:
  - `custom/power`: `@red`
  - `custom/reboot`: `@yellow`
  - `custom/suspend`: `@cyan`
  - `custom/lock`: `@purple`
  - `custom/quit`: `@blue`
- Hover state: Full background fill with module accent color, text `#181818`.
- Padding: `0 6px`, font-size: `13px`.
