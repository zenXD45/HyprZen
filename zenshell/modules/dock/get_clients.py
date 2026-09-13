import json
import subprocess
import os
import sys

def get_desktop_files():
    dirs = [
        "/usr/share/applications",
        os.path.expanduser("~/.local/share/applications")
    ]
    desktop_map = {}
    for d in dirs:
        if not os.path.exists(d): continue
        for root, _, files in os.walk(d):
            for f in files:
                if f.endswith(".desktop"):
                    path = os.path.join(root, f)
                    try:
                        with open(path, 'r', encoding='utf-8') as df:
                            content = df.read()
                            wm_class = None
                            icon = None
                            name = None
                            for line in content.split('\n'):
                                if line.startswith('StartupWMClass='):
                                    wm_class = line.split('=', 1)[1].strip()
                                elif line.startswith('Icon='):
                                    icon = line.split('=', 1)[1].strip()
                                elif line.startswith('Name=') and not name:
                                    name = line.split('=', 1)[1].strip()
                            
                            filename_base = f[:-8].lower()
                            
                            if icon:
                                if wm_class:
                                    desktop_map[wm_class.lower()] = icon
                                desktop_map[filename_base] = icon
                                if name:
                                    desktop_map[name.lower()] = icon
                    except:
                        pass
    return desktop_map

try:
    desktop_map = get_desktop_files()
    out = subprocess.check_output(["hyprctl", "clients", "-j"])
    clients = json.loads(out)
    
    for c in clients:
        cls = c.get("class", "").lower()
        icls = c.get("initialClass", "").lower()
        
        # Try to find icon
        icon = desktop_map.get(icls) or desktop_map.get(cls) or icls
        c["resolvedIcon"] = icon
        
        # Extract workspace ID
        ws = c.get("workspace", {})
        c["workspaceId"] = ws.get("id", 1)
        
    print(json.dumps(clients))
except Exception as e:
    print(json.dumps([]))
