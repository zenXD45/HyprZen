#!/usr/bin/env bash
# =============================================================
#  Dynamic Wallpaper Colors Generator (Pywal)
# =============================================================

if [ -z "$1" ]; then
    echo "Usage: dynamic-colors.sh <path-to-wallpaper>"
    exit 1
fi

WALLPAPER="$1"

# 1. Run pywal without changing the background (Hyprpaper/Swaybg handles that)
wal -i "$WALLPAPER" -n -q

# 2. Copy the generated templates to the themes directories as 'dynamic'
cp ~/.cache/wal/colors-hyprland.conf ~/.config/hypr/themes/dynamic.conf
cp ~/.cache/wal/colors-waybar.css ~/.config/waybar/themes/dynamic.css
cp ~/.cache/wal/colors-kitty.conf ~/.config/kitty/themes/dynamic.conf

# 3. Reload everything
echo "source = ~/.config/hypr/themes/dynamic.conf" > ~/.config/hypr/themes/current_theme.conf
ln -sf ~/.config/waybar/themes/dynamic.css ~/.config/waybar/themes/current.css
ln -sf ~/.config/kitty/themes/dynamic.conf ~/.config/kitty/themes/current.conf

hyprctl reload
pkill -SIGUSR2 waybar 2>/dev/null
pkill -SIGUSR1 kitty 2>/dev/null
swaync-client -rs 2>/dev/null || true

notify-send "󰟡 HyprZen" "Dynamic colors applied!" --icon=color-select
