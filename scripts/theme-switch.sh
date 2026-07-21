#!/usr/bin/env bash
# =============================================================
#  HyprZen Theme Switcher
#  Usage:
#    theme-switch.sh               → Rofi picker
#    theme-switch.sh <theme-name>  → Apply directly
# =============================================================

THEMES=(
    "catppuccin" "tokyo-night" "gruvbox" "nord" "osaka-jade"
    "aetheria" "akane" "alabaster" "lavender" "eva-theme" "noir"
)
DISPLAY_NAMES=(
    "☕ Catppuccin     — soothing pastel"
    "🌃 Tokyo Night    — clean dark blue"
    "📦 Gruvbox        — retro groove"
    "❄️ Nord           — arctic ice"
    "🪨 Osaka Jade     — deep green"
    "☁️ Aetheria      — light ethereal"
    "🏮 Akane          — japanese red"
    "🤍 Alabaster      — clean minimalist"
    "🪻 Lavender       — purple dark"
    "🤖 Eva Theme      — neon evangelion"
    "🌑 Noir           — soothing dark"
)

HYPR_DIR="$HOME/.config/hypr"
WAYBAR_THEME_DIR="$HOME/.config/waybar/themes"
KITTY_THEME_DIR="$HOME/.config/kitty/themes"
THEME_FILE="$HYPR_DIR/current_theme"
ROFI_THEME="$HOME/.config/rofi/anime.rasi"

# ── Select theme ───────────────────────────────────────────────
if [ -n "$1" ]; then
    SELECTED="$1"
else
    # Build rofi menu
    MENU=$(printf '%s\n' "${DISPLAY_NAMES[@]}")
    ROFI_ARGS=(-dmenu -p "󰟡 Theme" -selected-row 0)
    [ -f "$ROFI_THEME" ] && ROFI_ARGS+=(-theme "$ROFI_THEME")
    CHOICE=$(echo "$MENU" | rofi "${ROFI_ARGS[@]}")

    [ -z "$CHOICE" ] && exit 0

    # Map display name → theme id
    for i in "${!DISPLAY_NAMES[@]}"; do
        if [ "${DISPLAY_NAMES[$i]}" = "$CHOICE" ]; then
            SELECTED="${THEMES[$i]}"
            break
        fi
    done
fi

# Validate
VALID=false
for t in "${THEMES[@]}"; do
    [ "$t" = "$SELECTED" ] && VALID=true && break
done

if [ "$VALID" = false ]; then
    notify-send "HyprZen" "Unknown theme: $SELECTED" --icon=dialog-error
    exit 1
fi

# ── Apply theme ────────────────────────────────────────────────

# 1. Write theme name for Hyprlang config
echo "source = ~/.config/hypr/themes/$SELECTED.conf" > "$HYPR_DIR/themes/current_theme.conf"

# 2. Waybar CSS symlink
ln -sf "$WAYBAR_THEME_DIR/$SELECTED.css" "$WAYBAR_THEME_DIR/current.css"

# 3. Kitty theme symlink
ln -sf "$KITTY_THEME_DIR/$SELECTED.conf" "$KITTY_THEME_DIR/current.conf"

# 4. Rofi theme symlink
ln -sf "$HOME/.config/rofi/themes/$SELECTED.rasi" "$HOME/.config/rofi/colors.rasi"

# 5. Update Waypaper wallpaper folder to match theme
sed -i "s|^folder = .*|folder = ~/wallpapers/$SELECTED|" "$HOME/.config/waypaper/config.ini"

# 6. Reload Hyprland (re-reads current_theme via Lua)
hyprctl reload

# 7. Reload Waybar (picks up new CSS symlink)
pkill -SIGUSR2 waybar 2>/dev/null

# 8. Reload Kitty (sends SIGUSR1 to all kitty instances)
pkill -SIGUSR1 kitty 2>/dev/null

# 9. Reload SwayNC
swaync-client -rs 2>/dev/null || true

# 10. Notify user
notify-send "󰟡 HyprZen" "Theme: $SELECTED" \
    --icon=preferences-desktop-theme \
    --urgency=low \
    --expire-time=2000
