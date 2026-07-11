#!/usr/bin/env bash
# =============================================================
#  HyprZen Wallpaper Randomizer
#  Picks a random wallpaper, applies with swww, optionally
#  regenerates pywal palette.
# =============================================================

WALLPAPER_DIR="$HOME/wallpapers/walls"
CURRENT_LINK="$HOME/wallpapers/current"
USE_PYWAL=true   # Set false to skip pywal

# Check dir
if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "HyprZen" "Wallpaper dir not found: $WALLPAPER_DIR" --icon=dialog-error
    exit 1
fi

# Pick random file
WALL=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | shuf -n 1)

[ -z "$WALL" ] && exit 1

# Update symlink
ln -sf "$WALL" "$CURRENT_LINK"

# Apply with awww
awww img "$WALL" \
    --transition-type wipe \
    --transition-angle 30 \
    --transition-duration 1.5 \
    --transition-fps 60

# Pywal (optional)
if $USE_PYWAL; then
    wal -i "$WALL" -q --saturate 0.65 &
fi
