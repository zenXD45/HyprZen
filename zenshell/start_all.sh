#!/bin/bash
# Zen Shell - Master Launcher Script
# Starts the Dynamic Island, Dock, Desktop Widgets, and background daemons.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# Start background daemons (battery & bluetooth monitors)
if [ -f "$SCRIPT_DIR/start_monitors.sh" ]; then
    "$SCRIPT_DIR/start_monitors.sh" &
fi

# Launch Dynamic Island
quickshell -p "$SCRIPT_DIR" &

# Launch Dock
if [ -d "$SCRIPT_DIR/modules/dock" ]; then
    quickshell -p "$SCRIPT_DIR/modules/dock" &
fi

# Launch Desktop Widgets
if [ -d "$SCRIPT_DIR/modules/desktop-widgets" ]; then
    quickshell -p "$SCRIPT_DIR/modules/desktop-widgets" &
fi

print_info() { echo "[Zen Shell] Started all desktop shell components."; }
print_info
