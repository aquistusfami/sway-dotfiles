# Acid Dark File Chooser Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform the GTK file chooser dialog into a modern Acid Dark interface with deep black backgrounds, neon green accents, comfortable row padding, and styled headerbars.

**Architecture:** Create cohesive Acid Dark CSS definitions in `~/.config/gtk-3.0/gtk.css` and `~/.config/gtk-4.0/gtk.css`, mapping Adwaita/GTK color tokens and targeting `filechooser`, `places-sidebar`, `headerbar`, `treeview`, and `button` widgets.

**Tech Stack:** GTK 3 & GTK 4 CSS, `xdg-desktop-portal-gtk`, `busctl`, `grim`.

## Global Constraints
- Do not break compatibility with non-filechooser GTK apps.
- Maintain standard 96 DPI baseline and Geist font typography.
- Ensure all icons and text contrast ratios pass WCAG AA standards.

---

### Task 1: Create Acid Dark Colors Definitions
**Files:**
- Modify: `~/.config/gtk-3.0/colors.css`
- Modify: `~/.config/gtk-4.0/colors.css`

- [ ] **Step 1: Define Acid Dark color palette variables**
  Set `@define-color theme_bg_color #202020;`, `@define-color theme_fg_color #eff0eb;`, `@define-color theme_selected_bg_color #5af78e;`, `@define-color theme_selected_fg_color #161616;`, etc.
- [ ] **Step 2: Sync to GTK 4**
  Copy or match definitions in `~/.config/gtk-4.0/colors.css`.

---

### Task 2: Implement File Chooser Custom Styling
**Files:**
- Modify: `~/.config/gtk-3.0/gtk.css`
- Modify: `~/.config/gtk-4.0/gtk.css`

- [ ] **Step 1: Style HeaderBar and action buttons**
  Implement flat subtle Cancel button and neon green `#5af78e` Select button with 6px border-radius.
- [ ] **Step 2: Style Places Sidebar**
  Set background `#161616`, row padding, and subtle active highlight.
- [ ] **Step 3: Style TreeView and File List**
  Set row padding to 8px, clean header styling, and alternating subtle row backgrounds.
- [ ] **Step 4: Style minimalist slim scrollbars**
  Configure 4px width transparent scrollbar tracks with rounded sliders.

---

### Task 3: Verification & Visual Inspection
**Files:**
- Test Output: `~/.gemini/antigravity-cli/brain/4c60adfb-0997-4e0d-bbbd-658b329a1586/scratch/acid_dark_file_chooser.png`

- [ ] **Step 1: Restart `xdg-desktop-portal-gtk`**
  Run `systemctl --user restart xdg-desktop-portal-gtk`.
- [ ] **Step 2: Trigger file chooser dialog**
  Invoke DBus `OpenFile` method via `busctl`.
- [ ] **Step 3: Capture screenshot with `grim` and verify**
  Confirm aesthetic alignment with Acid Dark palette and visual balance.
