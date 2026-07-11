#!/bin/bash

# Get current power profile
current=$(powerprofilesctl get)

# Format options, adding a checkmark or indicator to the active one
opt_perf="Performance"
opt_bal="Balanced"
opt_save="Power Saver"

if [ "$current" = "performance" ]; then
    opt_perf="● Performance"
else
    opt_perf="○ Performance"
fi

if [ "$current" = "balanced" ]; then
    opt_bal="● Balanced"
else
    opt_bal="○ Balanced"
fi

if [ "$current" = "power-saver" ]; then
    opt_save="● Power Saver"
else
    opt_save="○ Power Saver"
fi

# Show rofi menu
choice=$(echo -e "$opt_perf\n$opt_bal\n$opt_save" | rofi -dmenu -p " Profile" -theme ~/.config/rofi/minimal.rasi)

# Set profile based on choice
case "$choice" in
    *"Performance")
        powerprofilesctl set performance
        notify-send "Power Profile" "Switched to Performance Mode 🚀"
        ;;
    *"Balanced")
        powerprofilesctl set balanced
        notify-send "Power Profile" "Switched to Balanced Mode ⚖️"
        ;;
    *"Power Saver")
        powerprofilesctl set power-saver
        notify-send "Power Profile" "Switched to Power Saver Mode 🔋"
        ;;
esac
