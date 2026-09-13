#!/bin/bash
CONF="$HOME/Desktop/hyprzen/.config/hypr/modules/keybinds.lua"

awk '
/^-- ── / {
    gsub(/^-- ── | ─+$/, "")
    print "───────────── " $0 " ─────────────"
}
/hl\.bind\(/ {
    line = $0
    
    match(line, /hl\.bind\(([^,]+),/, arr)
    key = arr[1]
    
    gsub(/^S \.\. " \+ /, "SUPER + ", key)
    gsub(/^SS \.\. " \+ /, "SUPER+SHIFT + ", key)
    gsub(/^SC \.\. " \+ /, "SUPER+CTRL + ", key)
    gsub(/^SA \.\. " \+ /, "SUPER+ALT + ", key)
    gsub(/"/, "", key)
    
    if (match(line, /, (.*)\)$/, arr2)) {
        action = arr2[1]
    } else if (match(line, /, (.*)$/, arr2)) {
        action = arr2[1]
    } else {
        action = ""
    }
    
    if (action ~ /^function/) {
        action = "Toggle scrolloverview"
    } else if (action ~ /^hl\.dsp\.exec_cmd\(/) {
        sub(/^hl\.dsp\.exec_cmd\("/, "", action)
        sub(/"\)$/, "", action)
    } else {
        # Clean up hyprland dispatchers
        gsub(/^hl\.dsp\./, "", action)
        gsub(/\(\{.*\}\)$/, "", action)
        gsub(/\(".*"\)$/, "", action)
        gsub(/\(\)$/, "", action)
    }
    
    printf "%-25s │ %s\n", key, action
}
' "$CONF" | rofi -dmenu -i -p "⌨️ Search Keybinds" -theme ~/.config/rofi/cheat.rasi
