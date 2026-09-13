#!/usr/bin/env python3
import sys
import os
import re
import json
import urllib.request
import urllib.parse

CACHE_DIR = "/tmp/dynamic_island_lyrics_cache"

def parse_lrc(lrc_text):
    lines = []
    pattern = re.compile(r'\[(\d+):(\d+(?:\.\d+)?)\](.*)')
    for line in lrc_text.splitlines():
        match = pattern.match(line.strip())
        if match:
            minutes = int(match.group(1))
            seconds = float(match.group(2))
            text = match.group(3).strip()
            if text:  # Ignore empty lines
                time_sec = minutes * 60 + seconds
                lines.append({"time": time_sec, "text": text})
    lines.sort(key=lambda x: x["time"])
    return lines

def get_lyrics(artist, title):
    if not artist and not title:
        print(json.dumps([]))
        return

    # Clean up Spotify-specific tags in the title that break LRCLIB searches
    title = re.sub(r'(?i) - (remastered|single version|radio edit|live|mono|stereo|deluxe|version).*', '', title).strip()
    title = re.sub(r'(?i) \((feat\.|with ).*\)', '', title).strip()
    
    # Also clean up the artist if it contains multiple artists separated by commas
    artist = artist.split(',')[0].strip()

    os.makedirs(CACHE_DIR, exist_ok=True)
    cache_key = re.sub(r'[^a-zA-Z0-9]', '_', f"{artist}_{title}".lower())
    cache_file = os.path.join(CACHE_DIR, f"{cache_key}.json")

    if os.path.exists(cache_file):
        try:
            with open(cache_file, "r") as f:
                print(f.read())
                return
        except Exception:
            pass

    # Fetch from LRCLIB
    try:
        url = f"https://lrclib.net/api/get?artist_name={urllib.parse.quote(artist)}&track_name={urllib.parse.quote(title)}"
        req = urllib.request.Request(url, headers={'User-Agent': 'DynamicIsland/1.0'})
        with urllib.request.urlopen(req, timeout=3) as resp:
            data = json.loads(resp.read().decode())
            synced = data.get("syncedLyrics", "")
            if synced:
                parsed = parse_lrc(synced)
                res_json = json.dumps(parsed)
                with open(cache_file, "w") as f:
                    f.write(res_json)
                print(res_json)
                return
    except Exception:
        pass

    # Fallback to search query
    try:
        query = f"{artist} {title}".strip()
        url = f"https://lrclib.net/api/search?q={urllib.parse.quote(query)}"
        req = urllib.request.Request(url, headers={'User-Agent': 'DynamicIsland/1.0'})
        with urllib.request.urlopen(req, timeout=3) as resp:
            results = json.loads(resp.read().decode())
            for item in results:
                synced = item.get("syncedLyrics", "")
                if synced:
                    parsed = parse_lrc(synced)
                    res_json = json.dumps(parsed)
                    with open(cache_file, "w") as f:
                        f.write(res_json)
                    print(res_json)
                    return
    except Exception:
        pass

    print(json.dumps([]))

if __name__ == "__main__":
    artist = sys.argv[1] if len(sys.argv) > 1 else ""
    title = sys.argv[2] if len(sys.argv) > 2 else ""
    with open("/tmp/dynamic_island_lyrics_debug.log", "a") as f:
        f.write(f"Called with artist='{artist}' title='{title}'\n")
    get_lyrics(artist, title)
