# HyprZen 🏝️

A monorepo merging two projects — **HyprZen** (Hyprland dotfiles & theming) and **Zen Shell** (Quickshell Dynamic Island desktop suite) — into one cohesive, conflict-free desktop experience where **ZenShell is the default UI** (launcher, bar, dock, spotlight, theme/wallpaper pickers).

- [HyprZen — the base rice](hyprzen/README.md): ultra-minimal Hyprland config, 13 themes, swaync notifications, eww desktop clock.
- [Zen Shell — the glassmorphic shell](zenshell/README.md): Dynamic Island, Dock, Spotlight, Desktop Widgets — replaces rofi and waybar entirely.

## Structure

```text
hyprzen/     Hyprland dotfiles & theming (installs to ~/.config, ~/scripts, ~/wallpapers)
zenshell/    Quickshell Dynamic Island suite (installs to ~/.config/quickshell/dynamic-island)
```

## Installation

> One command installs everything on a from-scratch (or existing) Arch install:
> official packages, AUR packages (tolerant of build failures), GeistMono Nerd
> Font, scroll-overview plugin, GPU drivers, configs, ZenShell, services, theme.

```bash
git clone https://github.com/zenXD45/HyprZen.git
cd HyprZen
./install.sh
```

What `install.sh` does, in order:

1. Installs all official packages (Hyprland, kitty, swaync, pipewire, cliphist, python, toolchain…). **No waybar, no rofi** — the island + dock replace them.
2. Installs an AUR helper (`paru`/`yay`) and the AUR packages: `quickshell-git`, `eww-git`, `hyprswitch`, `matugen`, `satty`, `hyprshot`, `waypaper`, `swayosd`, `bibata-cursor-theme`. Failures are warned, not fatal.
3. Downloads + caches **GeistMono Nerd Font**.
4. Adds + enables the **scroll-overview** hyprpm plugin.
5. Detects NVIDIA GPUs and installs `nvidia-dkms`/`nvidia-utils`.
6. Runs `hyprzen/install.sh` to symlink configs → `~/.config`, link `~/scripts`, copy wallpapers → `~/wallpapers`.
7. Installs ZenShell → `~/.config/quickshell/dynamic-island` (backs up existing).
8. Applies the default theme (`catppuccin`) and sets a default wallpaper.
9. Enables NetworkManager, bluetooth, power-profiles-daemon + pipewire session services.
10. Verifies key binaries/configs, warns if known deps are missing.

After install: **log into the `Hyprland` session** (or run `hyprctl reload`).
ZenShell autostarts via `exec.lua` → `start_all.sh`; no manual `exec-once` line needed.

### Manual (order matters)

Equivalent steps if you prefer to run the pieces yourself:

```bash
# 1. HyprZen base — dependencies + symlinks
cd hyprzen && ./setup.sh

# 2. ZenShell — Quickshell suite
cd zenshell && ./install.sh

# 3. Reload
SUPER + CTRL + R
```

## ⌨️ Unified Keybinds

All keybinds live in `hyprzen/.config/hypr/modules/keybinds.lua`. Combos are **unique**. ZenShell owns the primary UI actions on plain `SUPER+` keys (launcher, clipboard, cheatsheet, themes, wallpapers); HyprZen keeps terminal/app/system binds on their own keys. Media/brightness keys remain on the keyboard keys.

### Apps & Launcher
| Action | Shortcut |
| :--- | :--- |
| Terminal (Kitty) | `SUPER + Enter` |
| **App Launcher (ZenShell island)** | `SUPER + Space` |
| Window Switcher | `SUPER + Alt + Tab` |
| Browser (LibreWolf) | `SUPER + B` |
| Files (Nautilus) | `SUPER + E` |
| Editor (VSCodium) | `SUPER + C` |
| Desktop Clock | `SUPER + D` |

### ZenShell Dynamic Island
| Action | Shortcut |
| :--- | :--- |
| App Launcher | `SUPER + Space` |
| Keybinds Cheatsheet | `SUPER + comma` |
| Clipboard Manager | `SUPER + V` |
| Control Center | `SUPER + Shift + N` |
| Power Menu | `SUPER + Escape` |
| Power Profiles | `SUPER + Shift + P` |
| Spotlight Search | `SUPER + Shift + M` |

### Clipboard / Notifications
| Action | Shortcut |
| :--- | :--- |
| Clipboard (ZenShell island) | `SUPER + V` |
| Notifications (toggle) | `SUPER + N` |
| Notifications (dismiss) | `SUPER + Ctrl + N` |

### Theme / Wallpaper
| Action | Shortcut |
| :--- | :--- |
| Theme Switcher (island) | `SUPER + T` |
| Wallpaper Picker (island) | `SUPER + W` |

### Screenshots
| Action | Shortcut |
| :--- | :--- |
| Full screen | `Print` |
| Region → annotate | `SUPER + Print` |
| Region → clipboard | `SUPER + Ctrl + Print` |

### Windows / Workspaces
| Action | Shortcut |
| :--- | :--- |
| Close window | `SUPER + Q` |
| Fullscreen | `SUPER + F` |
| Maximize | `SUPER + Alt + F` |
| Toggle float | `SUPER + Shift + F` |
| Toggle pseudo | `SUPER + P` |
| Toggle opaque | `SUPER + O` |
| Focus | `SUPER + H/J/K/L` / arrows |
| Move window | `SUPER + Shift + H/J/K/L` |
| Resize window | `SUPER + Alt + arrows` |
| Workspace 1–10 | `SUPER + 1…0` |
| Move to workspace | `SUPER + Shift + 1…0` |
| Cycle workspace | `SUPER + Ctrl + ←/→`, `SUPER + scroll` |
| Overview | `SUPER + Tab` |
| Scratchpad (`special:magic`) | `SUPER + S` |

### Media / System
| Action | Shortcut |
| :--- | :--- |
| Volume / Mute / Mic | `XF86Audio*` |
| Brightness | `XF86MonBrightness*` |
| Playback / Next / Prev | `XF86AudioPlay/Next/Prev` |
| Lock | `SUPER + Shift + L` |
| Exit Hyprland | `SUPER + Ctrl + Q` |
| Reload config | `SUPER + Ctrl + R` |
| wlogout | `SUPER + X` |
| Caffeine (idle toggle) | `SUPER + Shift + C` |

## Notes

- **rofi and waybar are removed from HyprZen** — ZenShell's island (launcher, clipboard, cheatsheet, theme/wallpaper pickers) and dock are the default UI, so nothing can conflict.
- Both projects previously hardcoded absolute paths (e.g. `~/Desktop/hyprzen/...` and a user home dir); these were normalized to `~/scripts` and `~/wallpapers` (the symlinks `hyprzen/install.sh` creates), and every `$HOME` / user-directory path inside ZenShell now resolves via `$HOME` / `Qt.homePath()`, so the repo works on any machine without edits.
- Keep the install order above; ZenShell depends on HyprZen's `theme-switch.sh` for its ThemeSwitcher.