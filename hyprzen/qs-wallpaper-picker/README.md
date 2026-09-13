# qs-wallpaper-picker

A Quickshell wallpaper picker for Hyprland with support for image and video wallpapers, smooth animated transitions, and optional dynamic theming powered by matugen.

---

## Preview

<img width="2560" height="1600" alt="preview" src="https://github.com/user-attachments/assets/d14fce0d-4ef9-4cca-8c41-94e4ffd893bd" />

---

## Features

- Local wallpaper browsing
- Image and video wallpaper support
- Animated transitions via `awww`
- Video wallpaper support via `mpvpaper`
- Optional dynamic colors using `matugen`
- Optional Hyprland reload
- Optional Waybar reload
- Fully configurable behavior via `config/Settings.qml`

---

## Requirements

Core:
- `Hyprland`
- `Quickshell`

Wallpaper handling:
- `awww` (image transitions)
- `mpvpaper` (video wallpapers)

Optional:
- `matugen` (dynamic colors)
- `Waybar` (auto reload support)
---

## Installation

Clone the repository:

```bash
git clone https://github.com/magetsu002/qs-wallpaper-picker.git
cd qs-wallpaper-picker
```

Create your local configuration:

```bash
cp config/Settings.qml.example config/Settings.qml
```

Edit your configuration:

```bash
nano config/Settings.qml
```

Set your wallpaper directory:

```qml
property string wallpaperDir: homeDir + "/Wallpapers"
```

---

## Usage

Run the picker:

```bash
quickshell -p Main.qml
```

### Optional: Hyprland Keybind

Example keybind:

```ini
bind = SUPER, W, exec, quickshell -p ~/path/to/qs-wallpaper-picker/Main.qml
```

---

## Configuration

All behavior is controlled through:

```
config/Settings.qml
```

### You can control:

- Dynamic color generation
- Matugen integration
- Hyprland reload behavior
- Waybar reload behavior
- System integrations (kitty, cava, swaync, etc.)

---

## Dynamic Theming

Enable full dynamic theming:

```qml
property bool enableDynamicColors: true
property bool enableMatugen: true
property bool enableHyprReload: true
property bool enableWaybarReload: true
```

Disable for wallpaper-only usage:

```qml
property bool enableDynamicColors: false
property bool enableMatugen: false
property bool enableHyprReload: false
property bool enableWaybarReload: false
```

---

## Important Notes

- Do **not** edit `Settings.qml.example` directly.  
  Copy it to `Settings.qml` and edit that file instead.

- Your `Settings.qml` is **user-specific** and should not be committed.

---

## Warnings

- Do not run multiple theming tools simultaneously (e.g. pywal, other matugen scripts, custom watchers).  
  This can cause race conditions and unexpected color overrides.

- If colors change even when disabled, check for:
  - Background matugen processes
  - File watchers
  - External scripts modifying:
    - `~/.config/waybar/colors.css`
    - `~/.config/hypr/colors.conf`

- This tool assumes it is the **single source of truth** for:
  - wallpaper changes
  - dynamic color generation (if enabled)

- If using custom Waybar launch scripts, ensure the path in `Settings.qml` is correct.

---

## Credits

Wallpaper picker UI design adapted from:  
https://github.com/ilyamiro/nixos-configuration

Ported and extended for Arch Linux, Hyprland, and Quickshell.

---

## License

MIT License — see the LICENSE file for details.
