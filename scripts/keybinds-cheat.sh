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
    
    match(line, /, (.*)\)$/, arr2)
    action = arr2[1]
    
    if (action ~ /^function\(\)/) {
        action = "Custom Lua Function"
    } else if (match(action, /hl\.dsp\.exec_cmd\("([^"]+)"\)/, arr3)) {
        action = "exec: " arr3[1]
    } else {
        # Strip trailing options if present
        gsub(/, \{.*\}$/, "", action)
        action = "action: " action
    }
    
    printf "%-25s │ %s\n", key, action
}
' "$CONF" | rofi -dmenu -i -p "⌨️ Search Keybinds" -theme ~/.config/rofi/cheat.rasi
