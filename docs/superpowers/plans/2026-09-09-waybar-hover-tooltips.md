# Waybar Hover Tooltips Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Overhaul Waybar hover tooltips to eliminate outdated yellow borders and raw output, replacing them with a sharp Acid Dark aesthetic (0px square corners, flat `#181818` background, `#333333` border, concise formatted tooltips, and highlighted calendar).

**Architecture:** Update Waybar CSS stylesheets for global tooltip box styling and Waybar JSON configs for calendar markup and module tooltip formats. Verify live with Sway cursor hover and `grim` screenshots across both float and full modes.

**Tech Stack:** Waybar, GTK 3 CSS, Sway (`swaymsg`), `grim`.

## Global Constraints

- Strictly 0px `border-radius` everywhere.
- Flat styling: no gradients, no drop shadows (`box-shadow: none`).
- Color palette: `#181818` background, `#333333` border, `#eff0eb` text, `#57c7ff` cyan header, `#5af78e` green accent.
- Mirror all changes between `~/.config/waybar/` and `~/dotfiles/.config/waybar/` across `config.jsonc`, `config-float.jsonc`, `config-full.jsonc`, `style.css`, `style-float.css`, `style-full.css`.

---

### Task 1: Redesign Waybar Tooltip Stylesheet (CSS)

**Files:**
- Modify: `~/.config/waybar/style.css:34-43`
- Modify: `~/.config/waybar/style-float.css:34-43`
- Modify: `~/.config/waybar/style-full.css:34-43`

- [ ] **Step 1: Inspect current tooltip rules in all three CSS files**
Check `tooltip` and `tooltip label` selectors in `style.css`, `style-float.css`, `style-full.css`.

- [ ] **Step 2: Replace tooltip styling in `~/.config/waybar/style.css`**
Update to:
```css
tooltip {
    border: 1px solid #333333;
    border-radius: 0px;
    background: #181818;
    box-shadow: none;
    padding: 8px 12px;
}

tooltip label {
    font-family: "Geist", "JetBrainsMono Nerd Font", monospace;
    font-size: 12px;
    color: #eff0eb;
}
```

- [ ] **Step 3: Mirror changes to `style-float.css` and `style-full.css`**
Apply the exact same CSS snippet to `style-float.css` and `style-full.css`.

- [ ] **Step 4: Reload Waybar and verify CSS parsing without errors**
Run: `waybar --validate -s ~/.config/waybar/style.css`
Expected: No CSS syntax errors or warnings.

---

### Task 2: Configure Tooltip Content & Calendar in Waybar JSON Configs

**Files:**
- Modify: `~/.config/waybar/config.jsonc`
- Modify: `~/.config/waybar/config-float.jsonc`
- Modify: `~/.config/waybar/config-full.jsonc`

- [ ] **Step 1: Configure `clock` calendar formatting**
Add native calendar formatting inside `clock`:
```jsonc
    "clock": {
        "interval": 60,
        "format": "<span foreground='#929292'></span>&#8195;{:%d/%m %H:%M}",
        "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
        "calendar": {
            "mode": "month",
            "mode-mon-col": 3,
            "weeks-pos": "right",
            "on-scroll": 1,
            "format": {
                "months": "<span color='#57c7ff'><b>{}</b></span>",
                "days": "<span color='#eff0eb'>{}</span>",
                "weeks": "<span color='#929292'><b>W{}</b></span>",
                "weekdays": "<span color='#929292'><b>{}</b></span>",
                "today": "<span color='#181818' background='#5af78e'><b>{}</b></span>"
            }
        },
        "actions": {
            "on-scroll-up": "shift_up",
            "on-scroll-down": "shift_down"
        },
        "on-click": "/home/aquistus/.config/waybar/toggle-style.sh"
    },
```

- [ ] **Step 2: Clean up `cpu` and `memory` tooltip formats**
Replace 16-core raw output on CPU and raw dump on Memory with concise metrics:
```jsonc
    "cpu": {
        "interval": 3,
        "format": "<span foreground='#929292'></span>&#8195;{usage}%",
        "tooltip": true,
        "tooltip-format": "CPU: {usage}%\nLoad: {load}"
    },
    "memory": {
        "interval": 5,
        "format": "<span foreground='#929292'></span>&#8195;{percentage}%",
        "tooltip": true,
        "tooltip-format": "RAM: {used:0.1f}GB / {total:0.1f}GB ({percentage}%)\nSwap: {swap_used:0.1f}GB / {swap_total:0.1f}GB"
    },
```

- [ ] **Step 3: Clean up `battery`, `pulseaudio`, and `backlight` tooltips**
Add / refine tooltips:
```jsonc
    "battery": {
        "format-icons": ["", "", "", "", ""],
        "format": "<span foreground='#929292'>{icon}</span>&#8195;{capacity}%",
        "format-charging": "<span foreground='#929292'></span>&#8195;{capacity}%",
        "format-discharging": "<span foreground='#929292'>{icon}</span>&#8195;{capacity}%",
        "format-full": "<span foreground='#929292'></span>&#8195;{capacity}%",
        "interval": 30,
        "tooltip": true,
        "tooltip-format": "Pin: {capacity}%\nThời gian: {time}\nTrạng thái: {status}",
        "states": {
            "warning": 25,
            "critical": 10
        }
    },
    "pulseaudio": {
        "tooltip": true,
        "tooltip-format": "Âm lượng: {volume}%\nCổng: {desc}",
        ...
    },
    "backlight": {
        "tooltip": true,
        "tooltip-format": "Độ sáng: {percent}%",
        ...
    }
```

- [ ] **Step 4: Mirror all updates to `config-float.jsonc` and `config-full.jsonc`**

---

### Task 3: Sync to Dotfiles, Restart Waybar & Visual Verification

**Files:**
- Sync: `cp -rf ~/.config/waybar/* ~/dotfiles/.config/waybar/`

- [ ] **Step 1: Restart Waybar**
Run: `pkill -9 waybar; sleep 0.5; waybar &`

- [ ] **Step 2: Hover test Clock and capture screenshot**
Run: `swaymsg seat seat0 cursor set 1900 15 && sleep 0.6 && grim /tmp/clock_tooltip.png`
Verify: Monospace aligned calendar, cyan month header, green today highlight, 0px sharp dark box.

- [ ] **Step 3: Hover test CPU / RAM / Battery and capture screenshot**
Run: `swaymsg seat seat0 cursor set 1720 15 && sleep 0.6 && grim /tmp/cpu_tooltip.png`
Verify: Clean summary, no 16-core dump, 0px sharp dark box.

- [ ] **Step 4: Commit changes to Git in `~/dotfiles`**
Run: `git add .config/waybar docs/superpowers/plans && git commit -m "feat(waybar): overhaul hover tooltips to minimal Acid Dark aesthetic"`
