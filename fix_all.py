import os
import re

def fix_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Fix match = "class ^(name)$"
    content = re.sub(r'match\s*=\s*"class\s+(\^\(.*?\)\$)"', r'class = "\1"', content)
    
    # Fix namespace = "match:namespace ^(name)$"
    content = re.sub(r'namespace\s*=\s*"match:namespace\s+(\^\(.*?\)\$)"', r'namespace = "\1"', content)
    
    # Fix unquoted hex colors in themes
    if 'themes' in filepath or 'colors' in filepath:
        # Match variables assigned to a 6-digit number that starts with 0-9
        content = re.sub(r'([a-zA-Z_]+)\s*=\s*([0-9a-fA-F]{6})\b', r'\1 = "\2"', content)
        
    with open(filepath, 'w') as f:
        f.write(content)

for root, _, files in os.walk('.config/hypr'):
    for file in files:
        if file.endswith('.lua'):
            fix_file(os.path.join(root, file))

print("Fixed syntax errors.")
