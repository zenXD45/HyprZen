import re

with open('.config/hypr/modules/windowrules.lua', 'r') as f:
    content = f.read()

# Fix match = { match = "class ^(something)$" } to match = { class = "^(something)$" }
content = re.sub(r'match\s*=\s*"class\s*(.*?)"', r'class = "\1"', content)
content = re.sub(r'match\s*=\s*"title\s*(.*?)"', r'title = "\1"', content)

# Fix float, center, pin, idle_inhibit etc.
content = re.sub(r'-- TODO: review rule: "float 1"', r'float = true,', content)
content = re.sub(r'-- TODO: review rule: "pin 1"', r'pin = true,', content)
content = re.sub(r'-- TODO: review rule: "tile 1"', r'tile = true,', content)
content = re.sub(r'-- TODO: review rule: "idle_inhibit focus"', r'idle_inhibit = "focus",', content)
content = re.sub(r'-- TODO: review rule: "idle_inhibit fullscreen"', r'idle_inhibit = "fullscreen",', content)

with open('.config/hypr/modules/windowrules.lua', 'w') as f:
    f.write(content)

with open('.config/hypr/modules/keybinds.lua', 'r') as f:
    key_content = f.read()

# Fix binde to hl.binde if binde is used? wait, hl.bind in lua is just hl.bind
# resizeactive
key_content = re.sub(r'-- TODO: manual review \(unknown dispatcher: resizeactive\)\n-- hl\.bind\("(.*?)", hl\.dsp\.resizeactive\("(.*?)"\)\)', r'hl.bind("\1", hl.dsp.window.resize({ x = \2, relative = true }))', key_content)
# Since resizeactive("30 0") has two numbers, let's use a function to parse it.

def replace_resize(m):
    key = m.group(1)
    args = m.group(2).split()
    x = args[0]
    y = args[1]
    return f'hl.bind("{key}", hl.dsp.window.resize({{ x = {x}, y = {y}, relative = true }}))'

key_content = re.sub(r'-- TODO: manual review \(unknown dispatcher: resizeactive\)\n-- hl\.bind\("(.*?)", hl\.dsp\.resizeactive\("(.*?)"\)\)', replace_resize, key_content)

with open('.config/hypr/modules/keybinds.lua', 'w') as f:
    f.write(key_content)
