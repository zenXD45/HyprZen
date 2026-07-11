<div align="center">
  <img src="https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png" width="400" alt="palette" />
  
  <h1>🌸 HyprZen</h1>
  <p><b>An ultra-minimal, zen-inspired dotfiles setup for Hyprland on Arch Linux.</b></p>
  
  <p>
    <a href="#-features">Features</a> •
    <a href="#-showcase">Showcase</a> •
    <a href="#-installation">Installation</a> •
    <a href="#%EF%B8%8F-keybindings">Keybinds</a>
  </p>
</div>

---

## ✨ Features

- **Minimalist Aesthetic**: Pure, dark, and distraction-free workspace. No bloated UI, no cartoonish shadows—just clean lines and solid colors.
- **Dynamic Waybar**: Comes with a built-in Rofi-based theme switcher to instantly swap between three custom sleek bar layouts: `minimal`, `pill`, and `solid`.
- **Advanced Screenshots**: Fully integrated `hyprshot` and `satty`. Instantly capture regions, annotate them in a centered floating window, or copy them straight to your clipboard.
- **Smart Workspaces**: Workspaces 1-4 are always visible for consistency, while 5-10 generate dynamically only when you need them.
- **Interactive Cheatsheet**: Never forget a shortcut again. Press `SUPER + ,` to pull up a searchable, dynamically generated Rofi menu of all your keybindings.
- **Automated Setup**: A bulletproof `setup.sh` script that automatically installs dependencies via `pacman` and `yay`/`paru`, followed by an installer that safely backs up your old configs.

---

## 📸 Showcase

<div align="center">
  <h3>The Desktop & App Launcher</h3>
  <img src="assets/desktop.png" alt="Desktop and Rofi" width="800"/>

  <h3>Live Keybinds Cheatsheet</h3>
  <img src="assets/keybinds.png" alt="Keybinds Cheatsheet" width="800"/>

  <h3>Custom Fastfetch (Marin)</h3>
  <img src="assets/fastfetch.png" alt="Fastfetch" width="800"/>

  <h3>Dynamic Waybar Theme Switcher</h3>
  <img src="assets/waybar-switcher.png" alt="Waybar Switcher" width="800"/>

  <h3>SwayNC Control Center</h3>
  <img src="assets/notifications.png" alt="Notifications" width="800"/>

  <h3>Impala Network Manager</h3>
  <img src="assets/network.png" alt="Network Manager" width="800"/>
</div>

---

## 🚀 Installation

### Supported Distributions
HyprZen is heavily optimized for **Arch Linux** and Arch-based distributions. It has been tested and works flawlessly on:
- Arch Linux
- CachyOS
- EndeavourOS
- Manjaro / Garuda

### How to Install
The installation process is split into two scripts that work together automatically:
* **`setup.sh`**: Downloads and installs all the required programs (Hyprland, Waybar, etc.) using `pacman` and an AUR helper (`yay`/`paru`).
* **`install.sh`**: Safely backs up your old configuration files and symlinks the HyprZen aesthetic into your `~/.config` folder.

**1. Clone the repository:**
```bash
git clone https://github.com/zenXD45/HyprZen.git
cd HyprZen
```

**2. Run the automated setup:**
```bash
# This handles both dependencies (via setup.sh) and symlinking (via install.sh)
./setup.sh
```

**3. Reload Hyprland:**
Press `SUPER + CTRL + R` to reload Hyprland and apply all the new configurations.

---

## ⌨️ Keybindings

HyprZen uses an ultra-minimal keybind configuration. For a full, searchable list of your live keybinds, simply press `SUPER + ,` inside Hyprland.

| Action | Shortcut |
| :--- | :--- |
| **Terminal (Kitty)** | `SUPER + ENTER` |
| **App Launcher (Rofi)** | `SUPER + SPACE` |
| **Keybinds Cheatsheet** | `SUPER + ,` (Comma) |
| **Waybar Theme Switcher** | `SUPER + W` |
| **Close Window** | `SUPER + Q` |
| **Toggle Fullscreen** | `SUPER + F` |
| **Toggle Floating** | `SUPER + SHIFT + F` |
| **Region Screenshot (Annotate)** | `SUPER + Print` |
| **Region Screenshot (Clipboard)** | `SUPER + CTRL + Print` |
| **Dismiss Notifications** | `SUPER + SHIFT + N` |

---

## 🛠️ Structure

```text
HyprZen/
├── .config/
│   ├── dunst/        # Notification daemon theming
│   ├── fastfetch/    # Custom minimal tree-style fetch
│   ├── hypr/         # Core Hyprland configuration & rules
│   ├── kitty/        # Terminal emulator themes
│   ├── rofi/         # App launcher, clipboard, and cheatsheet menus
│   └── waybar/       # Status bar and modular styles
├── scripts/
│   ├── keybinds-cheat.sh   # Generates the live rofi cheatsheet
│   ├── wallpaper-random.sh # Handles background rotation
│   └── waybar-switcher.sh  # Live theme toggler
├── install.sh        # Core symlink installer and backup utility
└── setup.sh          # Dependency wrapper for Arch Linux
```

---
<div align="center">
  <i>Stay Minimal. Stay Zen.</i>
</div>
