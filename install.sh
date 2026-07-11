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

# ── Step 3: Purge Caelestia remnants from ~/.config/hypr ─────
# The old Caelestia setup left these loose files alongside our symlink.
HYPR_DIR="$CONFIG_DIR/hypr"

# Remove the dangling symlink or old real directory first
if [ -L "$HYPR_DIR/hypr" ]; then
    rm -f "$HYPR_DIR/hypr"
    echo "  removed broken symlink: ~/.config/hypr/hypr"
fi

# Caelestia-specific files/dirs to nuke
for item in hyprland.conf variables.conf dms hyprland scheme scripts current_theme; do
    target="$HYPR_DIR/$item"
    if [ -e "$target" ] || [ -L "$target" ]; then
        rm -rf "$target"
        echo "  removed: ~/.config/hypr/$item"
    fi
done

# ── Step 4: Remove old waybar / dunst / rofi / kitty dirs ────
# (could be real dirs from old setups, or broken symlinks)
for app in waybar dunst rofi kitty; do
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
link "$DOTFILES_DIR/.config/dunst"   "$CONFIG_DIR/dunst"
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

# Hyprland stores the active theme name (for theme-switch.sh)
echo "$DEFAULT_THEME" > "$CONFIG_DIR/hypr/current_theme"

# Waybar theme
ln -sfn "$CONFIG_DIR/waybar/themes/$DEFAULT_THEME.css" \
        "$CONFIG_DIR/waybar/themes/current.css"

# Kitty theme
ln -sfn "$CONFIG_DIR/kitty/themes/$DEFAULT_THEME.conf" \
        "$CONFIG_DIR/kitty/themes/current.conf"

# Dunst theme
ln -sfn "$CONFIG_DIR/dunst/themes/$DEFAULT_THEME.conf" \
        "$CONFIG_DIR/dunst/themes/current.conf"

echo ""
echo "✅ Done! Next steps:"
echo "   1. Add anime wallpapers to ~/wallpapers/anime/"
echo "   2. Install packages if not already: see README.md"
echo "   3. Log in to Hyprland (or restart: hyprctl reload)"
echo "   4. Switch themes: Super+Shift+T  or  ~/scripts/theme-switch.sh <theme>"
