#!/usr/bin/env python3
import os
import glob
import json

def get_wallpapers():
    wallpaper_dir = os.path.expanduser("~/Pictures/Wallpapers")
    wallpapers = []
    
    if os.path.exists(wallpaper_dir):
        patterns = ["*.jpg", "*.png", "*.jpeg", "*.webp"]
        for pattern in patterns:
            for filepath in glob.glob(os.path.join(wallpaper_dir, "**", pattern), recursive=True):
                filename = os.path.basename(filepath)
                wallpapers.append({
                    "path": filepath,
                    "filename": filename
                })
                
    wallpapers.sort(key=lambda x: x["filename"].lower())
    print(json.dumps(wallpapers))

if __name__ == "__main__":
    get_wallpapers()
