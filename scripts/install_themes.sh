#!/usr/bin/env bash

# Directories
HYPR_DIR="$HOME/.config/hypr/themes"
WAYBAR_DIR="$HOME/.config/waybar/themes"
KITTY_DIR="$HOME/.config/kitty/themes"
ROFI_DIR="$HOME/.config/rofi/themes"

mkdir -p "$HYPR_DIR" "$WAYBAR_DIR" "$KITTY_DIR" "$ROFI_DIR"

write_theme() {
    local name="$1"
    local bg="$2"
    local surf="$3"
    local over="$4"
    local act="$5"
    local inact="$6"
    local txt="$7"
    local sub="$8"
    local urg="$9"

    # Hyprland
    cat <<EOF > "$HYPR_DIR/${name}.conf"
\$bg = $bg
\$surface = $surf
\$overlay = $over
\$border_active = rgba(${act}ff)
\$border_inactive = rgba(${inact}ff)
\$rounding = 12
\$border_size = 2
\$gaps_in = 4
\$gaps_out = 8
\$blur_size = 4
\$blur_passes = 2
\$blur_vibrancy = 0.0
\$inactive_opacity = 0.90
\$shadow_color = rgba(00000000)
EOF

    # Waybar
    cat <<EOF > "$WAYBAR_DIR/${name}.css"
@define-color bg_base       #$bg;
@define-color bg_surface    rgba($((16#${surf:0:2})), $((16#${surf:2:2})), $((16#${surf:4:2})), 0.88);
@define-color bg_overlay    rgba($((16#${over:0:2})), $((16#${over:2:2})), $((16#${over:4:2})), 0.75);
@define-color accent        #$act;
@define-color accent_soft   rgba($((16#${act:0:2})), $((16#${act:2:2})), $((16#${act:4:2})), 0.18);
@define-color accent_glow   transparent;
@define-color secondary     #$act;
@define-color text          #$txt;
@define-color subtext       #$sub;
@define-color border_color  rgba($((16#${act:0:2})), $((16#${act:2:2})), $((16#${act:4:2})), 0.20);
@define-color urgent        #$urg;
EOF

    # Kitty
    cat <<EOF > "$KITTY_DIR/${name}.conf"
background            #$bg
foreground            #$txt
selection_background  #$act
selection_foreground  #$bg
cursor                #$act
cursor_text_color     #$bg
color0   #$over
color8   #$sub
color1   #$urg
color9   #$urg
color2   #$act
color10  #$act
color3   #$txt
color11  #$txt
color4   #$act
color12  #$act
color5   #$act
color13  #$act
color6   #$act
color14  #$act
color7   #$txt
color15  #$txt
url_color #$act
active_tab_background   #$act
active_tab_foreground   #$bg
inactive_tab_background #$surf
inactive_tab_foreground #$txt
EOF
    # Rofi
    cat <<EOF > "$ROFI_DIR/${name}.rasi"
* {
    surface: rgba($((16#${bg:0:2})), $((16#${bg:2:2})), $((16#${bg:4:2})), 0.75);
    surface-container-high: rgba($((16#${surf:0:2})), $((16#${surf:2:2})), $((16#${surf:4:2})), 0.50);
    primary: #$act;
    secondary-container: rgba($((16#${over:0:2})), $((16#${over:2:2})), $((16#${over:4:2})), 0.30);
    on-surface: #$txt;
    on-secondary-container: #$sub;
    outline: #$inact;
    error: #$urg;
    tertiary: #$act;
}
EOF
}

# name bg surf over act inact txt sub urg
write_theme "catppuccin" "1e1e2e" "181825" "11111b" "cba6f7" "313244" "cdd6f4" "a6adc8" "f38ba8"
write_theme "tokyo-night" "1a1b26" "1f2335" "15161e" "7aa2f7" "292e42" "c0caf5" "a9b1d6" "f7768e"
write_theme "gruvbox" "282828" "3c3836" "1d2021" "d79921" "504945" "ebdbb2" "a89984" "cc241d"
write_theme "nord" "2e3440" "3b4252" "242933" "88c0d0" "4c566a" "d8dee9" "e5e9f0" "bf616a"
write_theme "osaka-jade" "0f1715" "18221f" "080c0b" "1db954" "253631" "e2f3eb" "a3c9b9" "e05252"
write_theme "aetheria" "fafafa" "f0f0f0" "e5e5e5" "a3b8cc" "cccccc" "333333" "666666" "e57373"
write_theme "akane" "1a0f0f" "261717" "0d0707" "cc4343" "402626" "f2d9d9" "b38c8c" "ff4d4d"
write_theme "alabaster" "f7f7f7" "ffffff" "eeeeee" "555555" "dddddd" "111111" "888888" "cc3333"
write_theme "lavender" "1a1525" "221b33" "120e1a" "a37acc" "33284d" "e6d9f2" "a693bf" "ff6699"
write_theme "eva-theme" "1a0033" "26004d" "0d001a" "73e600" "390073" "e6ccff" "9933ff" "ff3300"

echo "Themes generated successfully!"
