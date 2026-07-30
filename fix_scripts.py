import re

def fix_file(filepath, replacements):
    with open(filepath, 'r') as f:
        content = f.read()
    for old, new in replacements:
        content = content.replace(old, new)
    with open(filepath, 'w') as f:
        f.write(content)

fix_file('scripts/dynamic-colors.sh', [
    ('~/.config/hypr/themes/dynamic.conf', '~/.config/hypr/themes/dynamic.lua'),
    ('echo "source = ~/.config/hypr/themes/dynamic.lua" > ~/.config/hypr/themes/current_theme.conf',
     'echo "require(\\"themes.dynamic\\")" > ~/.config/hypr/themes/current_theme.lua')
])

fix_file('scripts/wallpaper-selector.sh', [
    ('echo "source = ~/.config/hypr/themes/matugen.conf" > ~/.config/hypr/themes/current_theme.conf',
     'echo "require(\\"themes.matugen\\")" > ~/.config/hypr/themes/current_theme.lua')
])

fix_file('scripts/keybinds-cheat.sh', [
    ('keybinds.conf', 'keybinds.lua')
])
