#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
#   HyprZen Fusion — One-Shot Arch Installer
#
#   Installs the complete HyprZen desktop:
#     • HyprZen    — Hyprland rice (kitty, swayosd,
#                    themes, scripts, wallpapers)
#     • ZenShell   — Quickshell Dynamic Island / Dock / Spotlight /
#                    Desktop Widgets suite (default bar + launcher)
#
#   From-scratch friendly: takes a bare Arch install and leaves you
#   with a working, themed Hyprland session. Tolerant of missing
#   AUR packages (warns, keeps going) so nothing dead-ends.
#
#   Usage:  bash install.sh
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

# ── Colors / helpers ────────────────────────────────────────────────
B='\033[0;34m'; G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'
C='\033[0;36m'; M='\033[0;35m'; N='\033[0m'; BD='\033[1m'

log()  { printf "${B}  ->${N} %b\n" "$*"; }
ok()   { printf "${G}  ok${N} %b\n" "$*"; }
warn() { printf "${Y}  !!${N} %b\n" "$*"; }
err()  { printf "${R}  xx${N} %b\n" "$*"; }
step() { printf "\n${M}──────────────────────────────────────────────${N}\n${C}${BD}%b${BD}${N}\n${M}──────────────────────────────────────────────${N}\n" "$*"; }

banner() {
    if command -v figlet &> /dev/null; then
        figlet "HyprZen Fusion" | sed 's/^/    /'
    elif command -v toilet &> /dev/null; then
        toilet -f mono12 "HyprZen Fusion" | sed 's/^/    /'
    else
        cat <<'EOF'
    ┌──────────────────────────────────────────────┐
    │            H Y P R Z E N   F U S I O N        │
    │   Hyprland rice + Quickshell Dynamic Island  │
    └──────────────────────────────────────────────┘
EOF
    fi
    printf "      %bHyprZen (rice) + ZenShell (island/dock/spotlight)%b\n" "$C" "$N"
}

# ── Resolve script location ─────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
REPO_HYPRZEN="$SCRIPT_DIR/hyprzen"
REPO_ZENSHELL="$SCRIPT_DIR/zenshell"
DEFAULT_THEME="catppuccin"

# ── Preflight ───────────────────────────────────────────────────────
banner
printf "\n"

if [ "$(id -u)" -eq 0 ]; then
    err "Do not run as root. Run as your normal user; sudo is used internally."
    exit 1
fi
if ! command -v pacman &> /dev/null; then
    err "This installer targets Arch-based distributions (pacman not found)."
    exit 1
fi
for d in "$REPO_HYPRZEN" "$REPO_ZENSHELL"; do
    if [ ! -d "$d" ]; then
        err "Missing '$d'. Run this script from the root of the cloned HyprZen repo."
        exit 1
    fi
done

step "One-shot install: deps, configs, fonts, plugins, services, theme"
log "This will install packages and overwrite existing dotfiles."
log "(Backups are taken where needed.)"
sudo -v || { err "sudo required."; exit 1; }
printf "  Ready. Starting install in a moment...\n"
sleep 2

# ── Official packages ───────────────────────────────────────────────
step "Official packages (pacman)"
OFFICIAL_PKGS=(
    # Window / compositor & core UI
    hyprland hyprlock hypridle kitty wlogout
    xdg-desktop-portal-hyprland
    # ZenShell needs NO waybar/rofi — the island + dock are the default.
    # Notifications are owned by ZenShell's island, not swaync.
    # Audio / OSD / input
    pipewire pipewire-pulse wireplumber pavucontrol playerctl brightnessctl
    # Clipboard / screenshot / clipboard utils
    cliphist wl-clipboard
    # System bits
    polkit-gnome network-manager-applet upower bluez-utils power-profiles-daemon
    socat inotify-tools xdg-utils libnotify glib2
    # Wallpaper / theme pipeline
    awww imagemagick python-pywal
    # Terminal apps
    btop fastfetch cava thunar neovim
    # Toolchain (needed by AUR builds: matugen, quickshell)
    base-devel git cmake cpio pkgconf gcc make unzip wget curl jq npm ripgrep fd rust
    # Networks
    impala
    # Fonts / GTK theming
    ttf-jetbrains-mono-nerd noto-fonts-emoji adw-gtk3 papirus-icon-theme
    # Python (monitors / control scripts)
    python python-dbus python-gobject
)
log "Installing ${#OFFICIAL_PKGS[@]} official packages (--needed)..."
sudo pacman -S --needed --noconfirm "${OFFICIAL_PKGS[@]}"
ok "Official packages done."

# ── AUR helper ──────────────────────────────────────────────────────
step "AUR helper"
AUR_HELPER=""
if command -v paru &> /dev/null; then
    AUR_HELPER="paru"
elif command -v yay &> /dev/null; then
    AUR_HELPER="yay"
else
    log "No AUR helper found — installing paru (official repo)..."
    sudo pacman -S --needed --noconfirm paru
    AUR_HELPER="paru"
fi
ok "Using AUR helper: $AUR_HELPER"

# ── AUR packages (tolerant) ─────────────────────────────────────────
step "AUR packages"
# quickshell-git REQUIRED (conflicts with the older/stable 'quickshell').
# Everything else: helper + --needed skips whatever is already satisfied.
AUR_PKGS=(
    quickshell-git
    hyprswitch
    matugen
    satty
    hyprshot
    waypaper
    swayosd
    bibata-cursor-theme
)
FAILED_AUR=()
for pkg in "${AUR_PKGS[@]}"; do
    if pacman -Qi "$pkg" &> /dev/null; then
        ok "$pkg already installed."
        continue
    fi
    log "Installing $pkg..."
    if $AUR_HELPER -S --needed --noconfirm "$pkg" &> /tmp/hyprzen-aur-$pkg.log; then
        ok "$pkg installed."
    else
        warn "$pkg failed (see /tmp/hyprzen-aur-$pkg.log). Continuing."
        FAILED_AUR+=("$pkg")
    fi
done
if [ "${#FAILED_AUR[@]}" -gt 0 ]; then
    warn "Some AUR packages failed to build: ${FAILED_AUR[*]}"
    warn "You can retry later: $AUR_HELPER -S ${FAILED_AUR[*]}"
else
    ok "All AUR packages installed."
fi

# ── Fonts ───────────────────────────────────────────────────────────
step "GeistMono Nerd Font"
FONT_DIR="$HOME/.local/share/fonts/GeistMonoNerdFont"
if fc-list 2> /dev/null | grep -qi 'GeistMono.*Nerd'; then
    ok "GeistMono Nerd Font already installed."
else
    log "Downloading GeistMono Nerd Font..."
    mkdir -p "$FONT_DIR"
    curl -fL -o /tmp/geistmono.zip \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/GeistMono.zip" \
        && unzip -oq /tmp/geistmono.zip -d "$FONT_DIR" \
        && rm -f /tmp/geistmono.zip
    fc-cache -f &> /dev/null || true
    ok "Font cached."
fi

# ── Hyprland plugin ─────────────────────────────────────────────────
step "Scroll-overview plugin"
log "Adding hyprland-scroll-overview via hyprpm..."
hyprpm add https://github.com/yayuuu/hyprland-scroll-overview &> /tmp/hyprzen-hyprpm.log || warn "hyprpm add failed (log: /tmp/hyprzen-hyprpm.log)."
hyprpm enable scrolloverview &> /tmp/hyprzen-hyprpm-enable.log || warn "hyprpm enable failed (run at login; exec.lua reloads plugins on start)."

# ── GPU drivers ─────────────────────────────────────────────────────
step "GPU drivers"
if lspci 2> /dev/null | grep -Eiq 'vga.*nvidia|3d.*nvidia'; then
    log "NVIDIA GPU detected — installing nvidia-dkms + nvidia-utils."
    sudo pacman -S --needed --noconfirm nvidia-dkms nvidia-utils linux-headers \
        || warn "NVIDIA install failed; continue (Hyprland may still work via another GPU)."
    ok "NVIDIA drivers installed."
else
    ok "No NVIDIA GPU detected — skipping."
fi

# ── Deploy HyprZen configs ──────────────────────────────────────────
step "HyprZen configs (symlinks + scripts + wallpapers)"
log "Running hyprzen/install.sh ..."
bash "$REPO_HYPRZEN/install.sh" || warn "hyprzen/install.sh exited with errors."
ok "HyprZen configs deployed."

# ── Deploy ZenShell ─────────────────────────────────────────────────
step "ZenShell suite (Dynamic Island / Dock / Spotlight / Widgets)"
QS_DEST="$HOME/.config/quickshell/dynamic-island"
mkdir -p "$HOME/.config/quickshell"
if [ -d "$QS_DEST" ]; then
    bak="${QS_DEST}.bak.$(date +%Y%m%d_%H%M%S)"
    log "Existing install found — backing up to $bak"
    mv "$QS_DEST" "$bak"
fi
cp -r "$REPO_ZENSHELL" "$QS_DEST"
chmod +x "$QS_DEST"/*.sh
chmod +x "$QS_DEST"/scripts/*.sh "$QS_DEST"/scripts/*.py 2> /dev/null || true
find "$QS_DEST/modules" -type f \( -name '*.sh' -o -name '*.py' \) -exec chmod +x {} + 2> /dev/null || true
ok "ZenShell deployed to $QS_DEST"

# ── Apply default theme + wallpaper ─────────────────────────────────
step "Apply default theme: $DEFAULT_THEME"
if [ -f "$HOME/scripts/theme-switch.sh" ]; then
    "$HOME/scripts/theme-switch.sh" "$DEFAULT_THEME" \
        && ok "Theme $DEFAULT_THEME applied." \
        || warn "theme-switch.sh had issues (normal outside a desktop session)."
else
    warn "~/.config/hypr not linked? theme-switch.sh missing. Configs must be linked."
fi

if [ ! -e "$HOME/wallpapers/current" ]; then
    log "Setting a default wallpaper for $DEFAULT_THEME..."
    WALL="$(find "$HOME/wallpapers/$DEFAULT_THEME" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.webp' \) 2> /dev/null | head -n 1 || true)"
    if [ -n "$WALL" ]; then
        ln -sf "$WALL" "$HOME/wallpapers/current"
        ok "Default wallpaper set: $WALL"
    else
        warn "No wallpapers found for $DEFAULT_THEME — pick one later with Super+W (island picker)."
    fi
else
    ok "Wallpaper already set."
fi

# ── Services ────────────────────────────────────────────────────────
step "Enable system services"
sudo systemctl enable --now NetworkManager.service 2> /dev/null && ok "NetworkManager enabled" || warn "NetworkManager: skipped/failed"
sudo systemctl enable --now bluetooth.service 2> /dev/null && ok "bluetooth enabled" || warn "bluetooth: skipped/failed"
sudo systemctl enable --now power-profiles-daemon.service 2> /dev/null && ok "power-profiles-daemon enabled" || warn "power-profiles-daemon: skipped/failed"
log "Starting pipewire session services (idempotent)..."
systemctl --user enable --now pipewire.socket pipewire-pulse.socket wireplumber.service 2> /dev/null \
    && ok "pipewire session services enabled" || warn "pipewire session services: skipped (are you in a running session?)"

# ── Verification ────────────────────────────────────────────────────
step "Verification"
pass=0; fail=0
check() { # check <desc> <cmd...>
    local desc="$1"; shift
    if "$@" &> /dev/null; then
        ok "$desc"
        pass=$((pass+1))
    else
        warn "$desc — not found"
        fail=$((fail+1))
    fi
}
check "hyprland"        sh -c 'command -v Hyprland'
check "quickshell"      sh -c 'command -v quickshell'
check "kitty"           sh -c 'command -v kitty'
check "hypr [$HOME/.config/hypr]"   sh -c '[ -e "$HOME/.config/hypr" ]'
check "scripts [$HOME/scripts]"     sh -c '[ -e "$HOME/scripts" ]'
check "zen shell [$QS_DEST/shell.qml]" sh -c '[ -f "$HOME/.config/quickshell/dynamic-island/shell.qml" ]'
check "theme current_theme.conf"     sh -c '[ -f "$HOME/.config/hypr/themes/current_theme.conf" ]'
check "swayosd"         sh -c 'command -v swayosd-server'
check "cliphist"        sh -c 'command -v cliphist'

printf "\n${G}${BD}Checks passed: ${pass}${N}${R}${BD}   Failed: ${fail}${N}\n"

step "Done — reboot or restart"
cat <<'EOF'

    Next steps:
      1. Reboot, then log into the "Hyprland" session.
      2. Wallpaper picker:        Super+W
      3. Theme switcher:          Super+T
      4. Dynamic Island (the default launcher bar/UI):
           Launcher        Super+Space
           Control Center  Super+N
           Clipboard       Super+V
           Cheatsheet      Super+,
           Power menu      Super+Escape
           Power profiles  Super+Shift+P
           Spotlight       Super+Shift+M
      5. zen shell autostart is wired into exec.lua (start_all.sh).

    If any AUR package failed, retry with:
         paru -S --needed <pkg...>
EOF
printf "\n"

if [ "${#FAILED_AUR[@]}" -gt 0 ]; then
    warn "AUR packages that did NOT install: ${FAILED_AUR[*]}"
fi