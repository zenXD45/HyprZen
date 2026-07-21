#!/usr/bin/env bash
# =============================================================
#  HyprZen Full Setup Script
#  1. Installs all required dependencies (Arch Linux)
#  2. Runs the install.sh script to link configs
# =============================================================

set -e

echo "🌸 Starting HyprZen Setup..."

# Ensure we are on an Arch-based distro
if ! command -v pacman &> /dev/null; then
    echo "❌ Error: This script requires an Arch-based distribution (pacman not found)."
    exit 1
fi

echo "📦 Installing dependencies..."

# ── 1. Core Hyprland & Wayland UI ──
PKGS="hyprland hyprlock waybar rofi-wayland kitty swaync wlogout waypaper"

# ── 2. Utilities (Screenshots, Audio, Info, File Manager, Power) ──
PKGS="$PKGS hyprshot cliphist wl-clipboard playerctl btop pavucontrol fastfetch cava thunar power-profiles-daemon python-pywal hyprswitch neovim ripgrep fd npm"

# ── 3. Fonts ──
PKGS="$PKGS ttf-jetbrains-mono-nerd"

echo "Running pacman to install official packages..."
sudo pacman -S --needed --noconfirm $PKGS

# ── 4. AUR Packages (if needed) ──
# Note: swayosd-git, impala, and satty might require an AUR helper depending on your distro/repos.
AUR_PKGS="swayosd impala satty"

if command -v yay &> /dev/null; then
    echo "Running yay to install AUR packages..."
    yay -S --needed --noconfirm $AUR_PKGS
elif command -v paru &> /dev/null; then
    echo "Running paru to install AUR packages..."
    paru -S --needed --noconfirm $AUR_PKGS
else
    echo "⚠️  AUR helper (yay/paru) not found!"
    echo "   Please manually install these packages from the AUR if they failed above: $AUR_PKGS"
fi

echo "✅ Dependencies installed successfully!"
echo ""
echo "🔗 Proceeding to link configurations..."

# Run the existing symlink installer
if [ -f "./install.sh" ]; then
    chmod +x ./install.sh
    ./install.sh
else
    echo "❌ Error: install.sh not found in the current directory."
    exit 1
fi

echo "🎉 All done! You can now log into Hyprland."
