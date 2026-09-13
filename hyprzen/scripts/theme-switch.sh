#!/usr/bin/env bash
# =============================================================
#  HyprZen Theme Switcher
#  Called by the ZenShell island theme panel (with a theme id).
#  Usage:
#    theme-switch.sh <theme-name>  → Apply directly
# =============================================================

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

THEMES=(
    "catppuccin" "tokyo-night" "gruvbox" "nord" "osaka-jade"
    "aetheria" "akane" "alabaster" "lavender" "eva-theme" "noir"
    "one-dark" "rose-pine"
)

HYPR_DIR="$HOME/.config/hypr"
KITTY_THEME_DIR="$HOME/.config/kitty/themes"
THEME_FILE="$HYPR_DIR/current_theme"

# ── Get theme ─────────────────────────────────────────────────
if [ -z "${1:-}" ]; then
    echo "Usage: theme-switch.sh <theme-name>"
    exit 1
fi
SELECTED="$1"

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

# 2. Shared GUI colors for swayosd (waybar is gone; the CSS
#    variables now live alongside the theme instead)
ln -sfn "$HYPR_DIR/themes/$SELECTED.css" "$HYPR_DIR/themes/current.css"

# 3. Kitty theme symlink
ln -sf "$KITTY_THEME_DIR/$SELECTED.conf" "$KITTY_THEME_DIR/current.conf"

# 4. Update Waypaper wallpaper folder to match theme
if [ -f "$HOME/.config/waypaper/config.ini" ]; then
    sed -i "s|^folder = .*|folder = ~/wallpapers/$SELECTED|" "$HOME/.config/waypaper/config.ini"
fi

# 5. Reload Hyprland (re-reads current_theme via Lua)
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl reload
fi

# 6. Reload Kitty (sends SIGUSR1 to all kitty instances)
pkill -SIGUSR1 kitty 2>/dev/null || true

# 7. Reload SwayOSD to pick up the new CSS
killall swayosd-server 2>/dev/null || true
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    hyprctl dispatch exec swayosd-server >/dev/null 2>&1
fi

# 8. Sync Neovim Theme
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
    "one-dark") NVIM_THEME="onedark" ;;
    "rose-pine") NVIM_THEME="rose-pine" ;;
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

# 9. Sync VSCodium Theme
case "$SELECTED" in
    "noir") CODE_THEME="Noir Theme" ;;
    "catppuccin") CODE_THEME="Catppuccin Mocha" ;;
    "tokyo-night") CODE_THEME="Tokyo Night" ;;
    "gruvbox") CODE_THEME="Gruvbox Dark Hard" ;;
    "nord") CODE_THEME="Nord" ;;
    "osaka-jade") CODE_THEME="Everforest Dark" ;;
    "aetheria") CODE_THEME="Catppuccin Latte" ;;
    "akane") CODE_THEME="Kanagawa" ;;
    "alabaster") CODE_THEME="GitHub Light" ;;
    "lavender") CODE_THEME="Tokyo Night Moon" ;;
    "eva-theme") CODE_THEME="Tokyo Night Storm" ;;
    "one-dark") CODE_THEME="Atom One Dark" ;;
    "rose-pine") CODE_THEME="Rosé Pine" ;;
    *) CODE_THEME="Default Dark+" ;;
esac

VSCODE_SETTINGS="$HOME/.config/VSCodium/User/settings.json"
if [ -f "$VSCODE_SETTINGS" ]; then
    jq ".\"workbench.colorTheme\" = \"$CODE_THEME\"" "$VSCODE_SETTINGS" > "${VSCODE_SETTINGS}.tmp" && mv "${VSCODE_SETTINGS}.tmp" "$VSCODE_SETTINGS"
fi

# 10. Sync GTK and Kvantum Themes
case "$SELECTED" in
    "catppuccin") GTK_THEME="catppuccin-mocha-lavender-standard+default"; KV_THEME="catppuccin-mocha-lavender"; WLOGOUT_COLOR="rgba(180, 190, 254, 0.5)" ;;
    "tokyo-night") GTK_THEME="adw-gtk3-dark"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(122, 162, 247, 0.5)" ;;
    "gruvbox") GTK_THEME="Colloid-Dark"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(254, 128, 25, 0.5)" ;;
    "nord") GTK_THEME="Nordic"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(136, 192, 208, 0.5)" ;;
    "osaka-jade") GTK_THEME="Colloid-Dark"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(167, 192, 128, 0.5)" ;;
    "aetheria") GTK_THEME="Colloid-Light"; KV_THEME="KvLight"; WLOGOUT_COLOR="rgba(114, 135, 253, 0.5)" ;;
    "akane") GTK_THEME="adw-gtk3-dark"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(255, 93, 98, 0.5)" ;;
    "alabaster") GTK_THEME="Colloid-Light"; KV_THEME="KvLight"; WLOGOUT_COLOR="rgba(128, 128, 128, 0.5)" ;;
    "lavender") GTK_THEME="catppuccin-mocha-lavender-standard+default"; KV_THEME="catppuccin-mocha-lavender"; WLOGOUT_COLOR="rgba(180, 190, 254, 0.5)" ;;
    "eva-theme") GTK_THEME="Materia-dark"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(158, 206, 106, 0.5)" ;;
    "noir") GTK_THEME="adw-gtk3-dark"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(255, 255, 255, 0.15)" ;;
    "one-dark") GTK_THEME="AtomOneDarkTheme"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(97, 175, 239, 0.5)" ;;
    "rose-pine") GTK_THEME="Materia-dark"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(196, 167, 231, 0.5)" ;;
    *) GTK_THEME="adw-gtk3-dark"; KV_THEME="KvDark"; WLOGOUT_COLOR="rgba(255, 255, 255, 0.15)" ;;
esac

if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    if [ "$SELECTED" = "aetheria" ] || [ "$SELECTED" = "alabaster" ]; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' 2>/dev/null || true
    else
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
    fi
    gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME" 2>/dev/null || true
fi

if command -v kvantummanager &> /dev/null; then
    kvantummanager --set "$KV_THEME" 2>/dev/null || true
fi

# 11. Sync Wlogout hover color
WLOGOUT_CSS="$HOME/.config/wlogout/style.css"
if [ -f "$WLOGOUT_CSS" ]; then
    sed -i "s|background-color: .* /\* WLOGOUT_HOVER_COLOR \*/|background-color: $WLOGOUT_COLOR; /* WLOGOUT_HOVER_COLOR */|" "$WLOGOUT_CSS"
fi

# 12. Notify user
if [ -n "$WAYLAND_DISPLAY" ] || [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
    notify-send "󰟡 HyprZen" "Theme: $SELECTED" \
        --icon=preferences-desktop-theme \
        --urgency=low \
        --expire-time=2000 || true
fi
