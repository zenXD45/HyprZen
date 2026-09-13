#!/usr/bin/env python3
import os
import glob
import json
import configparser

def get_apps():
    app_dirs = [
        "/usr/share/applications",
        os.path.expanduser("~/.local/share/applications")
    ]
    
    apps = []
    seen_execs = set()
    
    for d in app_dirs:
        if not os.path.exists(d):
            continue
            
        for desktop_file in glob.glob(os.path.join(d, "**/*.desktop"), recursive=True):
            try:
                config = configparser.ConfigParser(interpolation=None)
                # Some desktop files have duplicate keys or garbage, strict=False helps
                config.read(desktop_file, encoding='utf-8')
                
                if 'Desktop Entry' in config:
                    entry = config['Desktop Entry']
                    if entry.get('NoDisplay', 'false').lower() == 'true':
                        continue
                        
                    name = entry.get('Name')
                    exec_cmd = entry.get('Exec')
                    icon = entry.get('Icon', '')
                    
                    if not name or not exec_cmd:
                        continue
                        
                    # Clean up exec command (remove %u, %f, etc)
                    clean_exec = exec_cmd.split('%')[0].strip()
                    
                    if clean_exec in seen_execs:
                        continue
                    seen_execs.add(clean_exec)
                    
                    apps.append({
                        "name": name,
                        "exec": clean_exec,
                        "icon": icon
                    })
            except Exception:
                continue
                
    apps.sort(key=lambda x: x["name"].lower())
    print(json.dumps(apps))

if __name__ == "__main__":
    get_apps()
