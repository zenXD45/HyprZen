#!/usr/bin/env bash
# =============================================================
#  HyprZen Wallpaper Setter (ZenShell is the default UI)
#  Usage:
#    wallpaper-selector.sh <path-to-image>
#
#  Sets the current wallpaper AND keeps ~/wallpapers/current in
#  sync so hyprlock + the on-boot wallpaper (awww) match the one
#  you pick inside the ZenShell island.
# =============================================================
set -euo pipefail

CURRENT_LINK="$HOME/wallpapers/current"
WALL="${1:-}"

if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
    echo "Usage: wallpaper-selector.sh <path-to-image>"
    exit 1
fi

# Keep the 'current' link in sync (hyprlock reads this at lock time,
# exec.lua feeds it to awww at session start).
mkdir -p "$HOME/wallpapers"
ln -sf "$WALL" "$CURRENT_LINK"

# Apply with awww (smooth transition)
awww img "$WALL" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-duration 1.2 \
    --transition-fps 60

# Auto-generate colors with Matugen (only if installed)
if command -v matugen &> /dev/null; then
    matugen image "$WALL" -m dark --source-color-index 0

    echo "source = ~/.config/hypr/themes/matugen.conf" > ~/.config/hypr/themes/current_theme.conf
    ln -sf ~/.config/kitty/themes/matugen.conf ~/.config/kitty/themes/current.conf

    # Refresh shared GUI colors (swayosd) if matugen rendered a css theme
    for cand in "$HOME/.cache/matugen/colors-waybar.css" "$HOME/.config/matugen/templates/colors-waybar.css"; do
        [ -f "$cand" ] && ln -sfn "$cand" ~/.config/hypr/themes/current.css && break
    done

    hyprctl reload 2>/dev/null || true
    pkill -SIGUSR1 kitty 2>/dev/null || true

    notify-send "󰟡 HyprZen" "Material You colors applied!" --icon=color-select 2>/dev/null || true
fi