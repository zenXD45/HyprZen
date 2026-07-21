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

- **Dynamic Island Waybar**: Completely replaces a boring static bar with a sleek, floating, expanding "dynamic island" pill in the top-center. You can also instantly swap between `minimal`, `pill`, and `dynamic-island` using `Super+Shift+W`.
- **Aesthetic Glassmorphism**: Stunning Kawase blur (3 passes), minimal 1px borders, and transparent background glass effects across all applications including Rofi, VS Code, and terminal windows.
- **Automated Wallpaper Downloader & Switcher**: Includes a custom `fetch_wallpapers.py` script that downloads 100+ high-res, aesthetic PC wallpapers (anime, cars, scenery) directly from Wallhaven! Pick them effortlessly through an immersive transparent Rofi grid GUI.
- **Advanced Screenshots**: Fully integrated `hyprshot` and `satty`. Instantly capture regions, annotate them in a centered floating window, or copy them straight to your clipboard.
- **Smart Workspaces**: Workspaces 1-4 are always visible for consistency, while 5-10 generate dynamically only when you need them.
- **Interactive Cheatsheet**: Never forget a shortcut again. Press `SUPER + ,` to pull up a searchable, dynamically generated Rofi menu of all your keybindings.
- **Automated Setup**: A bulletproof `setup.sh` script that automatically installs dependencies via `pacman` and `yay`/`paru`, followed by an installer that safely backups old configs and initializes dynamic themes.

---

## 📸 Showcase

<table align="center">
  <tr>
    <td align="center">
      <b>Clean Desktop Environment</b><br>
      <img src="assets/2.png" alt="Clean Desktop" width="400"/>
    </td>
    <td align="center">
      <b>Rofi App Launcher</b><br>
      <img src="assets/3.png" alt="App Launcher" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center">
      <b>Hyprswitch Window Switcher</b><br>
      <img src="assets/1.png" alt="Window Switcher" width="400"/>
    </td>
    <td align="center">
      <b>Tiled Window Management</b><br>
      <img src="assets/4.png" alt="Tiled Windows" width="400"/>
    </td>
  </tr>
  <tr>
    <td align="center">
      <b>Custom Fastfetch (Marin)</b><br>
      <img src="assets/5.png" alt="Fastfetch" width="400"/>
    </td>
    <td align="center">
      <b>SwayNC Control Center</b><br>
      <img src="assets/6.png" alt="Control Center" width="400"/>
    </td>
  </tr>
</table>

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
│   ├── power-profile.sh    # Rofi-based performance mode switcher
│   ├── wallpaper-random.sh # Handles background rotation
│   └── waybar-switcher.sh  # Live theme toggler
├── install.sh        # Core symlink installer and backup utility
└── setup.sh          # Dependency wrapper for Arch Linux
```

---
<div align="center">
  <i>Stay Minimal. Stay Zen.</i>
</div>
