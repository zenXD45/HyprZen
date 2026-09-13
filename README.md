# HyprZen 🏝️

A monorepo merging two projects — **HyprZen** (hyprland dotfiles) and **Zen Shell** (Quickshell Dynamic Island desktop suite) — into one cohesive, conflict-free desktop experience.

- [HyprZen — the base rice](hyprzen/README.md): ultra-minimal Hyprland config, 13 themes, dynamic waybar island, rofi menus.
- [Zen Shell — the glassmorphic shell](zenshell/README.md): Dynamic Island, Dock, Spotlight, widgets.

## Structure

```text
hyprzen/     Hyprland dotfiles & theming (installs to ~/.config, ~/scripts, ~/wallpapers)
zenshell/    Quickshell Dynamic Island suite (installs to ~/.config/quickshell/dynamic-island)
```

## Installation (order matters)

1. **HyprZen base** — dependencies + symlinks:
   ```bash
   cd hyprzen && ./setup.sh    # Arch dependency installer (runs install.sh too)
   ```
   Installs configs to `~/.config`, symlinks `~/scripts`, copies wallpapers to `~/wallpapers`.

2. **Zen Shell** — Quickshell suite (backup/install into `~/.config/quickshell`):
   ```bash
   cd zenshell && ./install.sh
   ```
   Add to your hypr config: `exec-once = ~/.config/quickshell/dynamic-island/start_all.sh`

3. Reload Hyprland: `SUPER + CTRL + R`

## ⌨️ Unified Keybinds

All keybinds live in `hyprzen/.config/hypr/modules/keybinds.lua`. Combos are **unique** — no project clashes: HyprZen (rofi, swaync, wlogout) keeps the plain `SUPER+` keys, ZenShell's island uses `SUPER+SHIFT+` variants.

### Apps & Launcher
| Action | Shortcut |
| :--- | :--- |
| Terminal (Kitty) | `SUPER + Enter` |
| App Launcher (rofi) | `SUPER + Space` |
| **App Launcher (ZenShell island)** | `SUPER + Shift + Space` |
| Command Runner (rofi) | `SUPER + R` |
| Window Switcher | `SUPER + Alt + Tab` |
| Browser (LibreWolf) | `SUPER + B` |
| Files (Nautilus) | `SUPER + E` |
| Editor (VSCodium) | `SUPER + C` |
| Desktop Clock | `SUPER + D` |

### ZenShell Dynamic Island
| Action | Shortcut |
| :--- | :--- |
| App Launcher | `SUPER + Shift + Space` |
| Keybinds Cheatsheet | `SUPER + Shift + comma` |
| Clipboard Manager | `SUPER + Shift + V` |
| Control Center | `SUPER + Shift + N` |
| Power Menu | `SUPER + Escape` |
| Power Profiles | `SUPER + Shift + P` |

### Clipboard / Notifications
| Action | Shortcut |
| :--- | :--- |
| Clipboard (cliphist → rofi) | `SUPER + V` |
| Notifications (toggle) | `SUPER + N` |
| Notifications (dismiss) | `SUPER + Ctrl + N` |

### Theme / Wallpaper / Waybar
| Action | Shortcut |
| :--- | :--- |
| Theme Switcher | `SUPER + T` |
| Waybar Layout Switcher | `SUPER + W` |
| Waybar Reload | `SUPER + Shift + W` |
| Wallpaper Picker | `SUPER + Alt + W` |

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

- Both projects previously hardcoded `~/Desktop/hyprzen/...` paths; these were normalized to `~/scripts` and `~/wallpapers` (the symlinks `hyprzen/install.sh` creates), so the repo can live anywhere.
- ZenShell's daemons and scripts still reference `/home/zen/...` in a few QML/Python files — adjust to your user before installing on another machine.
- Keep both install scripts in the order above; ZenShell depends on HyprZen's `theme-switch.sh` for its ThemeSwitcher.