# Waybar Power Menu Drawer Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a sleek, horizontal sliding power menu drawer (`group/power`) in Waybar with minimal Font Awesome icons and Acid Dark styling.

**Architecture:** Replace the static `custom/power` item in `config.jsonc`, `config-full.jsonc`, and `config-float.jsonc` with `group/power`. Define drawer actions (`custom/power`, `custom/reboot`, `custom/suspend`, `custom/lock`, `custom/quit`). Style in `style.css`, `style-float.css`, and `style-full.css`.

**Tech Stack:** Waybar (JSONC, CSS), Font Awesome 6.

## Global Constraints
- Icons: Font Awesome 6 (``, ``, ``, ``, ``).
- Drawer animation: `transition-left-to-right: false`, duration `300ms`.
- Acid Dark theme: `0px` border-radius, `2px` colored bottom border, flat hover color fill with `#181818` text.

---

### Task 1: Update Waybar JSON configurations

**Files:**
- Modify: `~/.config/waybar/config.jsonc` (via dotfiles)
- Modify: `~/.config/waybar/config-full.jsonc` (via dotfiles)
- Modify: `~/.config/waybar/config-float.jsonc` (via dotfiles)

- [ ] **Step 1: Update `config.jsonc`**
Replace `"custom/power"` with `"group/power"` in `modules-right`. Add `"group/power"` configuration with child action modules.
- [ ] **Step 2: Update `config-full.jsonc`**
Apply the same `group/power` definition.
- [ ] **Step 3: Update `config-float.jsonc`**
Apply the same `group/power` definition.
- [ ] **Step 4: Commit**
```bash
git add .config/waybar/*.jsonc
git commit -m "feat(waybar): configure group/power drawer in jsonc configs"
```

---

### Task 2: Update Waybar CSS stylesheets

**Files:**
- Modify: `~/.config/waybar/style.css` (via dotfiles)
- Modify: `~/.config/waybar/style-full.css` (via dotfiles)
- Modify: `~/.config/waybar/style-float.css` (via dotfiles)

- [ ] **Step 1: Update `style.css`**
Add `#group-power` and styling for `#custom-power`, `#custom-reboot`, `#custom-suspend`, `#custom-lock`, `#custom-quit`.
- [ ] **Step 2: Update `style-full.css`**
Apply identical styles.
- [ ] **Step 3: Update `style-float.css`**
Apply identical styles.
- [ ] **Step 4: Commit**
```bash
git add .config/waybar/*.css
git commit -m "style(waybar): add Acid Dark power drawer styles"
```

---

### Task 3: Reload and verify live drawer

- [ ] **Step 1: Reload Waybar**
Run `pkill -SIGUSR2 waybar`.
- [ ] **Step 2: Verify drawer behavior**
Check that Waybar loads without JSON syntax errors and drawer expands smoothly on hover.
