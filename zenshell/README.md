<div align="center">
  <h1>Zen Shell 🏝️</h1>
  <p><b>A complete, ultra-sleek, glassmorphic Desktop Shell Suite (Dynamic Island, Dock, Spotlight Search & Desktop Widgets) built for Hyprland using Quickshell.</b></p>
  
  <p>
    <img src="https://img.shields.io/badge/Desktop-Hyprland-blue?style=for-the-badge&logo=linux" alt="Hyprland" />
    <img src="https://img.shields.io/badge/Shell-Quickshell-purple?style=for-the-badge&logo=qt" alt="Quickshell" />
    <img src="https://img.shields.io/badge/Scripts-Python%20%7C%20Bash-yellow?style=for-the-badge&logo=python" alt="Python & Bash" />
  </p>
</div>

---

Zen Shell brings a unified, modern desktop experience to your Linux environment. It combines an interactive **Dynamic Island**, a glassmorphic **Application Dock**, a macOS-style **Spotlight Search**, and customizable **Desktop Widgets**.

## ✨ Suite Features

- **Interactive Dynamic Island**: Live Now Playing media, lyrics sync, active Notifications, and smooth Volume/Brightness OSD controls.
- **Glassmorphic Dock**: Interactive bottom taskbar with active window indicators and application shortcuts.
- **Spotlight Search**: Fast, center-screen fuzzy application finder.
- **Desktop Widgets & Clock**: Sleek wallpaper-integrated widgets for Weather, System Stats, and Time.
- **Control Center**: System toggles for Wi-Fi, Bluetooth, Caffeine mode, and Microphone muting in real-time.
- **Keybinds Cheatsheet**: Live, searchable index of your `hyprland` shortcuts mapped to clean actions.
- **Clipboard Manager**: Powered by `cliphist`, view and decode recent clipboard history instantly.
- **Wallpaper & Theme Selectors**: Change your system's aesthetic on the fly.

## 📸 Previews

Below are some previews of Zen Shell in action!

<p align="center">
  <img src="assets/preview1.png" alt="Preview 1" width="45%" />
  <img src="assets/preview2.png" alt="Preview 2" width="45%" />
</p>
<p align="center">
  <img src="assets/preview3.png" alt="Preview 3" width="45%" />
  <img src="assets/preview4.png" alt="Preview 4" width="45%" />
</p>
<p align="center">
  <img src="assets/preview5.png" alt="Preview 5" width="45%" />
  <img src="assets/preview6.png" alt="Preview 6" width="45%" />
</p>
<p align="center">
  <img src="assets/preview7.png" alt="Preview 7" width="90%" />
</p>

## 🚀 One-Click Installation

To make getting started as easy as possible, Zen Shell includes a robust, automated installation script. 

The installer will safely backup any existing configurations, resolve all your system dependencies (via `yay` or `paru`), and ensure all scripts have the correct execution permissions.

Simply run the following command in your terminal:

```bash
git clone https://github.com/zenXD45/Zen-Shell.git ~/.config/quickshell/dynamic-island
~/.config/quickshell/dynamic-island/install.sh
```

*(Note: If you run into a password prompt, it's just your AUR helper safely fetching missing dependencies like `socat` or `playerctl`!)*

## ⚙️ Hyprland Integration

Once installed, you must tell Hyprland to launch Zen Shell on boot. Add the following lines to your configuration depending on whether you use the standard `.conf` or a Lua-based setup.

### Standard `hyprland.conf`

```ini
# Start the full Zen Shell Desktop Suite on boot
exec-once = ~/.config/quickshell/dynamic-island/start_all.sh
```

### Lua Configuration (e.g. `hyprland-lua`)

If you use a Lua-based Hyprland config:

```lua
-- Start the full Zen Shell Desktop Suite on boot
hl.exec_cmd("~/.config/quickshell/dynamic-island/start_all.sh")
```

### Keybind Setup

You can bind the different modules to whatever keys you prefer! 

**Standard `.conf` bindings:**
```ini
# App Launcher
bind = SUPER, Space, exec, ~/.config/quickshell/dynamic-island/island_ctl.sh launcher

# Keybinds Cheatsheet
bind = SUPER, comma, exec, ~/.config/quickshell/dynamic-island/island_ctl.sh cheatsheet

# Clipboard Manager
bind = SUPER, V, exec, ~/.config/quickshell/dynamic-island/island_ctl.sh clipboard

# Control Center
bind = SUPER_SHIFT, N, exec, ~/.config/quickshell/dynamic-island/island_ctl.sh control_center

# Power Menu
bind = SUPER, Escape, exec, ~/.config/quickshell/dynamic-island/island_ctl.sh power
```

**Lua bindings:**
```lua
hl.bind("SUPER", "Space", "exec", "~/.config/quickshell/dynamic-island/island_ctl.sh launcher")
hl.bind("SUPER", "comma", "exec", "~/.config/quickshell/dynamic-island/island_ctl.sh cheatsheet")
hl.bind("SUPER", "V", "exec", "~/.config/quickshell/dynamic-island/island_ctl.sh clipboard")
hl.bind("SUPER_SHIFT", "N", "exec", "~/.config/quickshell/dynamic-island/island_ctl.sh control_center")
hl.bind("SUPER", "Escape", "exec", "~/.config/quickshell/dynamic-island/island_ctl.sh power")
```

## 🛠️ Directory Structure

The repository is built to be extremely clean and easy to modify:
- `shell.qml`: The main Quickshell entry point and root window logic.
- `island_ctl.sh`: The core bash controller for opening/closing modules via IPC.
- `components/`: All modular QML UI elements (e.g. `AppLauncher.qml`, `ControlPanel.qml`).
- `scripts/`: Modular backend scripts (Python/Bash) that handle system data parsing.
- `assets/`: Upscaled screenshots and repository imagery.

Enjoy your beautiful new desktop!
