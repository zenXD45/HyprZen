#!/usr/bin/env bash
# =============================================================
#  Waytrogen Post Script
#  Executed automatically by waytrogen when a wallpaper is picked
# =============================================================

MONITOR=$1
WALLPAPER=$2

if [ -f "$WALLPAPER" ]; then
    # Update the global symlink used by other scripts/tools
    ln -sf "$WALLPAPER" ~/wallpapers/current
fi
