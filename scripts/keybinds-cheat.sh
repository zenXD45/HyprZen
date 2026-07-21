#!/bin/bash
CONF="$HOME/Desktop/hyprzen/.config/hypr/modules/keybinds.conf"

awk '
/^# ── / {
    gsub(/^# ── | ─+$/, "")
    print "───────────── " $0 " ─────────────"
}
/^bind[a-z]* =/ {
    line = $0
    sub(/^bind[a-z]* = /, "", line)
    
    # Split by comma
    n = split(line, parts, ",")
    
    mod = parts[1]
    key = parts[2]
    
    cmd = ""
    for(i=3; i<=n; i++) {
        cmd = cmd (i==3 ? "" : ",") parts[i]
    }
    
    # Trim spaces
    gsub(/^[ \t]+|[ \t]+$/, "", mod)
    gsub(/^[ \t]+|[ \t]+$/, "", key)
    gsub(/^[ \t]+|[ \t]+$/, "", cmd)
    
    # Replace variables
    if(mod == "$S") mod = "SUPER"
    else if(mod == "$SS") mod = "SUPER+SHIFT"
    else if(mod == "$SC") mod = "SUPER+CTRL"
    else if(mod == "$SA") mod = "SUPER+ALT"
    
    # Format beautifully
    printf "%-25s │ %s\n", mod " + " key, cmd
}
' "$CONF" | rofi -dmenu -i -p "⌨️ Search Keybinds" -theme ~/.config/rofi/cheat.rasi
