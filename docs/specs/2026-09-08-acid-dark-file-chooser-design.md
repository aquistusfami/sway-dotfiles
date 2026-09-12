# Acid Dark File Chooser Redesign Specification

## 1. Problem Statement
The default GTK 3 & GTK 4 file chooser dialog (`xdg-desktop-portal-gtk`) uses generic Adwaita Dark styling with low contrast gray-on-gray headerbars, standard blue selection highlights, and cramped table row heights. This clashes visually with the user's custom **Acid Dark / Snazzy** aesthetic (deep black background, neon green `#5af78e`, cyan `#57c7ff`, pink `#ff6ac1`).

## 2. Goals & Non-Goals
- **Goals**:
  - Redesign the file chooser dialog via clean, maintainable GTK 3 and GTK 4 CSS.
  - Implement full Acid Dark color palette (background `#202020`, header `#181818`, sidebar `#161616`, neon green `#5af78e` accents).
  - Increase table row heights and spacing for comfortable reading of file names, dates, and sizes.
  - Style the primary action button ("Select" / "Open") with high-contrast neon green and modern rounded corners.
  - Implement slim, minimalist scrollbars.
- **Non-Goals**:
  - Do not replace the underlying portal backend with unstable custom scripts.
  - Do not alter non-GTK application themes.

## 3. UI Component Architecture & Styling
- **HeaderBar**:
  - Background: `#181818`, border-bottom: `1px solid #2a2a2a`.
  - Normal buttons: background `rgba(255, 255, 255, 0.05)`, border `1px solid #333333`, border-radius `6px`.
  - Suggested action button: background `#5af78e`, color `#161616`, font-weight `600`, border-radius `6px`. Hover `#6ef99d`.
  - Search box: background `#262626`, border `1px solid #3a3a3a`, border-radius `6px`. Focus border `#5af78e`.
  - Breadcrumbs / Path bar: Pill-shaped buttons with rounded edges and subtle hover states.
- **Places Sidebar**:
  - Background: `#161616`, border-right: `1px solid #2a2a2a`.
  - Item padding: `8px 12px`, border-radius `6px`.
  - Hover state: `rgba(255, 255, 255, 0.05)`.
  - Active item: background `rgba(90, 247, 142, 0.15)`, text color `#5af78e`.
- **File List (TreeView & IconView)**:
  - Background: `#202020`.
  - Headers: background `#1a1a1a`, border-bottom `1px solid #2a2a2a`, text `#888888`, font-size `11px`.
  - Row padding: `8px 10px`.
  - Alternating row background: `#202020` / `#242424`.
  - Selected row: `rgba(90, 247, 142, 0.20)` with high contrast white text.
- **Scrollbars**:
  - Width: `4px`.
  - Slider: `rgba(255, 255, 255, 0.2)` with rounded caps. Hover: `rgba(90, 247, 142, 0.6)`.

## 4. Target Files
- `~/.config/gtk-3.0/gtk.css`
- `~/.config/gtk-4.0/gtk.css`
- `~/.config/gtk-3.0/colors.css` (redefined with Acid Dark tokens)
- `~/.config/gtk-4.0/colors.css` (redefined with Acid Dark tokens)

## 5. Verification Plan
- Restart `xdg-desktop-portal-gtk`.
- Trigger test file dialog via `busctl`.
- Capture screenshot using `grim` and visually confirm:
  - Neon green "Select" button.
  - Deep black sidebar and main list.
  - Comfortable row heights and crisp Geist typography.
