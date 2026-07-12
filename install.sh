#!/usr/bin/env bash
# =============================================================
#  HyprZen Install Script
#  Removes Caelestia setup and replaces with HyprZen.
#  Symlinks all configs from ~/Desktop/hyprzen to ~/.config.
# =============================================================

set -e

DOTFILES_DIR="$HOME/Desktop/hyprzen"
CONFIG_DIR="$HOME/.config"
DEFAULT_THEME="void-black"

echo "🌸 HyprZen Install"
echo "══════════════════"

# ── Step 1: Kill Caelestia / old shell components ────────────
echo ""
echo "🗑  Removing Caelestia setup..."

# Kill any Caelestia-related processes gracefully
for proc in caelestia ags quickshell hyprshell; do
    pkill -x "$proc" 2>/dev/null && echo "  killed: $proc" || true
done

# ── Step 2: Wipe Caelestia config dir ────────────────────────
if [ -d "$CONFIG_DIR/caelestia" ]; then
    rm -rf "$CONFIG_DIR/caelestia"
    echo "  removed: ~/.config/caelestia"
fi

# ── Step 3: (Removed) ────────────────────────────────────────
# We no longer delete individual files here because it could resolve our
# own symlink and delete files inside the git repository.
# Step 5 will cleanly replace the entire ~/.config/hypr directory anyway.
HYPR_DIR="$CONFIG_DIR/hypr"

# ── Step 4: Remove old waybar / swaync / rofi / kitty dirs ────
# (could be real dirs from old setups, or broken symlinks)
for app in waybar swaync rofi kitty; do
    target="$CONFIG_DIR/$app"
    if [ -L "$target" ]; then
        rm -f "$target"
        echo "  removed symlink: ~/.config/$app"
    elif [ -d "$target" ]; then
        # Backup only if not already backed up
        if [ ! -e "${target}.caelestia.bak" ]; then
            mv "$target" "${target}.caelestia.bak"
            echo "  backed up: ~/.config/$app  →  ~/.config/${app}.caelestia.bak"
        else
            rm -rf "$target"
            echo "  removed: ~/.config/$app"
        fi
    fi
done

# Also clean up the nested broken symlinks inside rofi/waybar if leftover
for item in "$CONFIG_DIR/rofi/rofi" "$CONFIG_DIR/waybar/waybar"; do
    [ -L "$item" ] && rm -f "$item" && echo "  removed nested symlink: $item" || true
done

# ── Step 5: Symlink HyprZen configs ──────────────────────────
echo ""
echo "🔗 Linking HyprZen configs..."

link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    ln -sfn "$src" "$dst"
    echo "  linked: $dst → $src"
}

# The hypr dir itself: wipe loose files and symlink the whole dir
# Since ~/.config/hypr might have leftover loose files, replace entirely
if [ -e "$HYPR_DIR" ] && [ ! -L "$HYPR_DIR" ]; then
    rm -rf "$HYPR_DIR"
    echo "  cleaned up: ~/.config/hypr (old Caelestia dir)"
fi
link "$DOTFILES_DIR/.config/hypr"    "$CONFIG_DIR/hypr"
link "$DOTFILES_DIR/.config/waybar"  "$CONFIG_DIR/waybar"
link "$DOTFILES_DIR/.config/kitty"   "$CONFIG_DIR/kitty"
link "$DOTFILES_DIR/.config/swaync"  "$CONFIG_DIR/swaync"
link "$DOTFILES_DIR/.config/rofi"    "$CONFIG_DIR/rofi"

# ── Step 6: Install scripts ───────────────────────────────────
echo ""
echo "📜 Installing scripts..."
mkdir -p "$HOME/scripts"
cp "$DOTFILES_DIR/scripts/"*.sh "$HOME/scripts/"
chmod +x "$HOME/scripts/"*.sh
echo "  installed: ~/scripts/"

# ── Step 7: Create wallpaper / screenshot dirs ────────────────
mkdir -p "$HOME/wallpapers/anime"
mkdir -p "$HOME/screenshots"
echo "  created: ~/wallpapers/anime/  ~/screenshots/"

# ── Step 8: Apply default theme ──────────────────────────────
echo ""
echo "🎨 Applying default theme: $DEFAULT_THEME"

if [ -f "$HOME/scripts/theme-switch.sh" ]; then
    "$HOME/scripts/theme-switch.sh" "$DEFAULT_THEME"
else
    echo "⚠️  theme-switch.sh not found, skipping default theme setup."
fi

echo ""
echo "✅ Done! Next steps:"
echo "   1. Add anime wallpapers to ~/wallpapers/anime/"
echo "   2. Install packages if not already: see README.md"
echo "   3. Log in to Hyprland (or restart: hyprctl reload)"
echo "   4. Switch themes: Super+Shift+T  or  ~/scripts/theme-switch.sh <theme>"
