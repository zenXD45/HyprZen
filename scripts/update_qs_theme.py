import re, json, sys
css_file = sys.argv[1]
out_file = sys.argv[2]
theme = {}
with open(css_file, 'r') as f:
    for line in f:
        match = re.match(r'@define-color\s+([a-zA-Z0-9_]+)\s+([^;]+);', line.strip())
        if match:
            theme[match.group(1)] = match.group(2).strip()
with open(out_file, 'w') as f:
    json.dump(theme, f, indent=2)
