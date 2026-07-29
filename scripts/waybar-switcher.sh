#!/bin/bash

# Define waybar directory
WAYBAR_DIR="$HOME/.config/waybar"
THEMES_DIR="$WAYBAR_DIR/themes"

# Options
OPTIONS="dynamic-island\nminimal\npill"

# Show rofi menu
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "  Style" -theme ~/.config/rofi/minimal.rasi)

if [ -n "$CHOICE" ]; then
    # Create symlinks
    ln -sf "$THEMES_DIR/$CHOICE/config.jsonc" "$WAYBAR_DIR/config.jsonc"
    ln -sf "$THEMES_DIR/$CHOICE/style.css" "$WAYBAR_DIR/style.css"

    # Reload waybar
    killall -SIGUSR2 waybar
    notify-send "Waybar" "Style changed to $CHOICE"
fi
