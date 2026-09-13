#!/usr/bin/env bash

# Toggle hypridle for "Caffeine" mode (keep screen awake)
if pidof hypridle > /dev/null; then
    killall hypridle
    notify-send -u normal -t 3000 -i "weather-clear-night" "Caffeine Enabled" "Screen will stay awake."
else
    hypridle &
    notify-send -u normal -t 3000 -i "weather-clear" "Caffeine Disabled" "Normal sleep schedule restored."
fi
