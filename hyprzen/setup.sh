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
# Note: 'rofi' (v2.0+) has native Wayland support (provides rofi-wayland).
# Using 'rofi' as the package name since 'rofi-wayland' is a virtual provide,
# not an installable package name on most Arch-based repos.
PKGS="hyprland hyprlock waybar rofi kitty swaync"

# ── 2. Utilities (Screenshots, Audio, Info, File Manager, Power) ──
PKGS="$PKGS cliphist wl-clipboard playerctl btop pavucontrol fastfetch cava thunar power-profiles-daemon python-pywal neovim ripgrep fd npm jq awww cmake cpio pkgconf gcc make unzip wget"

# ── 3. Fonts ──
PKGS="$PKGS ttf-jetbrains-mono-nerd"

echo "Running pacman to install official packages..."
sudo pacman -S --needed --noconfirm $PKGS

# ── 4. AUR / Extra Packages ──
# Some of these may be in the official repos on CachyOS or need an AUR helper.
# imagemagick and wlogout may already be in official repos; --needed handles that.
AUR_PKGS="impala satty quickshell imagemagick wlogout waypaper hyprshot"

# swayosd may already be satisfied by swayosd-git; only add if not provided
if ! pacman -Qi swayosd &>/dev/null && ! pacman -Qi swayosd-git &>/dev/null; then
    AUR_PKGS="swayosd $AUR_PKGS"
fi

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

echo "🔤 Installing GeistMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts/GeistMono"
if [ ! -d "$FONT_DIR" ]; then
    mkdir -p "$FONT_DIR"
    wget -q --show-progress -O /tmp/GeistMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.1/GeistMono.zip"
    unzip -q /tmp/GeistMono.zip -d "$FONT_DIR"
    rm /tmp/GeistMono.zip
    fc-cache -fv &>/dev/null
    echo "✅ GeistMono Nerd Font installed!"
else
    echo "✅ GeistMono Nerd Font already installed."
fi
echo ""

echo "🧩 Installing Hyprland Plugins..."
if command -v hyprpm &> /dev/null; then
    hyprpm update || true
    hyprpm add https://github.com/yayuuu/hyprland-scroll-overview.git || true
    hyprpm enable scrolloverview || true
    echo "✅ Hyprland plugins installed!"
else
    echo "⚠️  hyprpm not found. Please install hyprland headers/plugins manager."
fi

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
