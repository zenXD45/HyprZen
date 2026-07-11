#!/usr/bin/env bash
# =============================================================
#  HyprZen Wallpaper Selector
#  Displays a grid of wallpapers with thumbnails using Rofi
# =============================================================

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/"s
CURRENT_LINK="$HOME/wallpapers/current"
USE_PYWAL=false

if [ ! -d "$WALLPAPER_DIR" ]; then
    notify-send "HyprZen" "Wallpaper directory not found: $WALLPAPER_DIR" --icon=dialog-error
    exit 1
fi

# Generate rofi menu entries with image thumbnails
ENTRIES=""
while IFS= read -r file; do
    filename=$(basename "$file")
    # Rofi syntax for icons: Name\0icon\x1f/path/to/icon
    ENTRIES+="${filename}\0icon\x1f${file}\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [ -z "$ENTRIES" ]; then
    notify-send "HyprZen" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Display rofi with a custom grid layout for image thumbnails
CHOICE=$(echo -en "$ENTRIES" | rofi -dmenu -i -p " Select Wallpaper" \
    -theme-str '
    window { width: 45%; }
    listview { columns: 3; lines: 3; flow: horizontal; spacing: 10px; }
    element { orientation: vertical; padding: 15px; border-radius: 12px; }
    element-icon { size: 160px; }
    element-text { horizontal-align: 0.5; vertical-align: 0.5; }
    ')

if [ -z "$CHOICE" ]; then
    exit 0
fi

WALL="$WALLPAPER_DIR/$CHOICE"

if [ ! -f "$WALL" ]; then
    exit 1
fi

# Update symlink
ln -sf "$WALL" "$CURRENT_LINK"

# Apply with swww (smooth transition)
swww img "$WALL" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-duration 1.2 \
    --transition-fps 60

if $USE_PYWAL; then
    wal -i "$WALL" -q --saturate 0.65 &
fi
