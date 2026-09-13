#!/usr/bin/env python3
import sys
import os
import json
import subprocess
import glob

def parse_desktop_file(path):
    name, exec_cmd, icon = "", "", ""
    try:
        with open(path, "r", encoding="utf-8") as f:
            for line in f:
                if line.startswith("Name=") and not name:
                    name = line.split("=", 1)[1].strip()
                elif line.startswith("Exec=") and not exec_cmd:
                    exec_cmd = line.split("=", 1)[1].strip()
                elif line.startswith("Icon=") and not icon:
                    icon = line.split("=", 1)[1].strip()
        if name and exec_cmd:
            return {"type": "app", "name": name, "exec": exec_cmd, "icon": icon}
    except Exception:
        pass
    return None

def search_apps(query):
    query_lower = query.lower()
    apps = []
    seen_names = set()
    dirs = [
        "/usr/share/applications",
        os.path.expanduser("~/.local/share/applications")
    ]
    for d in dirs:
        for path in glob.glob(os.path.join(d, "**", "*.desktop"), recursive=True):
            app = parse_desktop_file(path)
            if app and app["name"] not in seen_names:
                if query_lower in app["name"].lower() or query_lower in path.lower():
                    apps.append(app)
                    seen_names.add(app["name"])
    
    # Sort apps: Exact matches or starts with query first
    apps.sort(key=lambda x: (not x["name"].lower().startswith(query_lower), x["name"].lower()))
    return apps[:8] # Return top 8 app matches

def search_files(query):
    home = os.path.expanduser("~")
    dirs_to_search = [
        os.path.join(home, ".config"),
        os.path.join(home, "Desktop"),
        os.path.join(home, "Documents"),
        os.path.join(home, "Downloads"),
        os.path.join(home, "Pictures"),
        os.path.join(home, "Music"),
        os.path.join(home, "Videos"),
    ]
    # We use fd if available for blazing fast search
    try:
        # -i = case insensitive, -a = absolute path, -H = hidden, -I = no ignore, -t f = only files
        cmd = ["fd", "-i", "-a", "-H", "-I", "-t", "f", "-c", "never", query] + [d for d in dirs_to_search if os.path.exists(d)]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=1.0)
        paths = result.stdout.splitlines()
        
        files = []
        for path in paths[:12]: # Top 12 file matches
            name = os.path.basename(path)
            # Determine icon based on extension
            ext = os.path.splitext(name)[1].lower()
            icon = "text-x-generic"
            if ext in [".png", ".jpg", ".jpeg", ".gif", ".svg"]: icon = "image-x-generic"
            elif ext in [".mp4", ".mkv", ".webm"]: icon = "video-x-generic"
            elif ext in [".mp3", ".wav", ".flac"]: icon = "audio-x-generic"
            elif ext in [".pdf"]: icon = "application-pdf"
            elif ext in [".zip", ".tar", ".gz"]: icon = "package-x-generic"
            elif ext in [".conf", ".json", ".xml", ".yaml", ".ini"]: icon = "text-x-script"
            elif ext in [".py", ".js", ".html", ".css", ".cpp", ".c", ".h", ".sh"]: icon = "text-x-script"
            
            files.append({"type": "file", "name": name, "path": path, "icon": icon})
        return files
    except Exception as e:
        return []

if __name__ == "__main__":
    if len(sys.argv) < 2 or not sys.argv[1].strip():
        print(json.dumps([]))
        sys.exit(0)
    
    query = sys.argv[1].strip()
    apps = search_apps(query)
    files = search_files(query)
    
    # Combine results
    results = apps + files
    print(json.dumps(results))
