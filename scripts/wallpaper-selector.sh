#!/usr/bin/env bash
# =============================================================
#  HyprZen Wallpaper Selector
#  Displays a grid of wallpapers with thumbnails using Rofi
# =============================================================

WALLPAPER_DIR="$HOME/wallpapers"
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
    theme_name=$(basename $(dirname "$file"))
    # Rofi syntax for icons: Name\0icon\x1f/path/to/icon
    ENTRIES+="[${theme_name}] ${filename}\0icon\x1f${file}\n"
done < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [ -z "$ENTRIES" ]; then
    notify-send "HyprZen" "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Display rofi with a custom transparent glass grid layout
CHOICE=$(echo -en "$ENTRIES" | rofi -dmenu -show-icons -i -p "Select Wallpaper" \
    -theme-str '
    * { 
        background-color: transparent; 
        text-color: #ffffff; 
        font: "JetBrainsMono Nerd Font 11"; 
    }
    window { 
        width: 75%; 
        background-color: rgba(20, 21, 23, 0.5); 
        border: 1px;
        border-color: rgba(255, 255, 255, 0.1); 
        border-radius: 15px; 
        padding: 30px; 
    }
    mainbox { children: [ inputbar, listview ]; spacing: 25px; }
    inputbar { 
        background-color: rgba(30, 32, 36, 0.4); 
        border-radius: 8px; 
        padding: 12px 20px; 
        children: [ prompt, entry ];
    }
    prompt { text-color: #8fd3c6; font: "JetBrainsMono Nerd Font 11"; margin: 0 15px 0 0; }
    entry { placeholder: "Type to filter..."; placeholder-color: rgba(255,255,255,0.4); text-color: #ffffff; }
    listview { 
        columns: 5; 
        lines: 2; 
        spacing: 20px; 
        fixed-height: false;
    }
    element { 
        orientation: vertical; 
        padding: 15px; 
        border-radius: 12px; 
        background-color: rgba(36, 38, 43, 0.4); 
    }
    element normal.normal { background-color: rgba(36, 38, 43, 0.4); text-color: #ffffff; }
    element alternate.normal { background-color: rgba(36, 38, 43, 0.4); text-color: #ffffff; }
    element selected.normal { background-color: #8fd3c6; text-color: #1a1b26; }
    element hover { background-color: rgba(255, 255, 255, 0.1); }
    element-icon { size: 240px; horizontal-align: 0.5; }
    element-text { horizontal-align: 0.5; vertical-align: 0.5; margin: 10px 0 0 0; font: "JetBrainsMono Nerd Font 10"; text-color: inherit; }
    ')

if [ -z "$CHOICE" ]; then
    exit 0
fi

# Extract theme and filename from "[theme] filename"
THEME_NAME=$(echo "$CHOICE" | awk -F'[][]' '{print $2}')
FILE_NAME=$(echo "$CHOICE" | sed 's/^\[.*\] //')
WALL="$WALLPAPER_DIR/$THEME_NAME/$FILE_NAME"

if [ ! -f "$WALL" ]; then
    exit 1
fi

# Update symlink
ln -sf "$WALL" "$CURRENT_LINK"

# Apply with awww (smooth transition)
awww img "$WALL" \
    --transition-type grow \
    --transition-pos 0.5,0.5 \
    --transition-duration 1.2 \
    --transition-fps 60

# Auto-generate colors with Matugen
matugen image "$WALL" -m dark --source-color-index 0

# Apply the matugen theme 
echo "source = ~/.config/hypr/themes/matugen.conf" > ~/.config/hypr/themes/current_theme.conf
ln -sf ~/.config/waybar/themes/matugen.css ~/.config/waybar/themes/current.css
ln -sf ~/.config/kitty/themes/matugen.conf ~/.config/kitty/themes/current.conf

# Reload UI
hyprctl reload
pkill -SIGUSR2 waybar 2>/dev/null
pkill -SIGUSR1 kitty 2>/dev/null
swaync-client -rs 2>/dev/null || true
killall swayosd-server 2>/dev/null || true
swayosd-server >/dev/null 2>&1 &

notify-send "󰟡 HyprZen" "Material You colors applied!" --icon=color-select
