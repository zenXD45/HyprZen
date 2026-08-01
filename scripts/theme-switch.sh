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

# 1. Write theme name for Hyprlang config and Hyprlock
echo "require(\"themes.$SELECTED\")" > "$HYPR_DIR/themes/current_theme.lua"
echo "source = ~/.config/hypr/themes/$SELECTED.conf" > "$HYPR_DIR/themes/current_theme.conf"

# 2. Waybar CSS symlink
ln -sf "$WAYBAR_THEME_DIR/$SELECTED.css" "$WAYBAR_THEME_DIR/current.css"

# 3. Kitty theme symlink
ln -sf "$KITTY_THEME_DIR/$SELECTED.conf" "$KITTY_THEME_DIR/current.conf"

# 4. Rofi theme symlink
ln -sf "$HOME/.config/rofi/themes/$SELECTED.rasi" "$HOME/.config/rofi/colors.rasi"

# 5. Update Waypaper wallpaper folder to match theme
if [ -f "$HOME/.config/waypaper/config.ini" ]; then
    sed -i "s|^folder = .*|folder = ~/wallpapers/$SELECTED|" "$HOME/.config/waypaper/config.ini"
fi

# 5.1 Update Quickshell wallpaper picker directory
if [ -f "$HOME/Desktop/hyprzen/qs-wallpaper-picker/config/Settings.qml" ]; then
    sed -i "s|property string wallpaperDir:.*|property string wallpaperDir: homeDir + \"/wallpapers/$SELECTED\"|" "$HOME/Desktop/hyprzen/qs-wallpaper-picker/config/Settings.qml"
fi

# 5.2 Generate thumbnails for the new theme
if [ -x "$HOME/Desktop/hyprzen/qs-wallpaper-picker/scripts/generate_thumbs.sh" ]; then
    "$HOME/Desktop/hyprzen/qs-wallpaper-picker/scripts/generate_thumbs.sh" "$HOME/wallpapers/$SELECTED" >/dev/null 2>&1 &
    disown
fi

# 6. Reload Hyprland (re-reads current_theme via Lua)
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl reload
fi

# 7. Reload Waybar (picks up new CSS symlink)
pkill -SIGUSR2 waybar 2>/dev/null || true

# 8. Reload Kitty (sends SIGUSR1 to all kitty instances)
pkill -SIGUSR1 kitty 2>/dev/null || true

# 9. Reload SwayOSD to pick up the new CSS
killall swayosd-server 2>/dev/null || true
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl dispatch exec swayosd-server >/dev/null 2>&1
fi

# 9. Reload SwayNC
if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    timeout 3 swaync-client -rs 2>/dev/null || true
fi

# 10. Sync Neovim Theme
case "$SELECTED" in
    "noir") NVIM_THEME="carbonfox" ;;
    "catppuccin") NVIM_THEME="catppuccin-mocha" ;;
    "tokyo-night") NVIM_THEME="tokyonight" ;;
    "gruvbox") NVIM_THEME="gruvbox" ;;
    "nord") NVIM_THEME="nord" ;;
    "osaka-jade") NVIM_THEME="everforest" ;;
    "aetheria") NVIM_THEME="catppuccin-latte" ;;
    "akane") NVIM_THEME="kanagawa" ;;
    "alabaster") NVIM_THEME="github_light" ;;
    "lavender") NVIM_THEME="tokyonight-moon" ;;
    "eva-theme") NVIM_THEME="tokyonight-storm" ;;
    *) NVIM_THEME="pywal" ;;
esac

STATE_FILE="$HOME/.local/state/nvim/settings_state.json"
mkdir -p "$(dirname "$STATE_FILE")"
if [ -f "$STATE_FILE" ]; then
    jq ".theme = \"$NVIM_THEME\"" "$STATE_FILE" > "${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
else
    echo "{\"theme\": \"$NVIM_THEME\"}" > "$STATE_FILE"
fi

for server in $(find /run/user/$(id -u)/nvim* -type s 2>/dev/null); do
    timeout 3 nvim --server "$server" --remote-send "<ESC>:lua require('ui_theme').apply_theme('$NVIM_THEME')<CR>" 2>/dev/null || true
done

# 11. Sync GTK color-scheme (for Librewolf and other apps)
if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    if [ "$SELECTED" = "aetheria" ] || [ "$SELECTED" = "alabaster" ]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    fi
fi

# 12. Notify user
if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    notify-send "󰟡 HyprZen" "Theme: $SELECTED" \
        --icon=preferences-desktop-theme \
        --urgency=low \
        --expire-time=2000 || true
fi
