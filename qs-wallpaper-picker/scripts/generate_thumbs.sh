#!/bin/bash
WP_DIR="$1"
THUMB_DIR="$HOME/.cache/wallpaper_picker/thumbs"
mkdir -p "$THUMB_DIR"

if command -v magick &> /dev/null; then CMD="magick"; else CMD="convert"; fi

for file in "$WP_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if [ ! -f "$THUMB_DIR/$filename" ]; then
            $CMD "$file" -resize x420 -quality 70 "$THUMB_DIR/$filename" || true
        fi
    fi
done
