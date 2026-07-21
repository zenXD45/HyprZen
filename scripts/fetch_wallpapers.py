import os
import requests
import time

themes = {
    "catppuccin": {"query": "vaporwave", "color": "ea4c88"},
    "tokyo-night": {"query": "tokyo night", "color": "333399"},
    "gruvbox": {"query": "autumn", "color": "cc6633"},
    "nord": {"query": "snow mountains", "color": "0099cc"},
    "osaka-jade": {"query": "dark forest", "color": "336600"},
    "aetheria": {"query": "fantasy landscape", "color": "66cccc"},
    "akane": {"query": "jdm", "color": "cc3333"},
    "alabaster": {"query": "minimalist", "color": "ffffff"},
    "lavender": {"query": "galaxy", "color": "993399"},
    "eva-theme": {"query": "evangelion", "color": "663399"}
}

base_dir = os.path.expanduser("~/wallpapers")

for theme, data in themes.items():
    query = data["query"]
    color = data["color"]
    print(f"Fetching 10 cool high-res wallpapers for {theme}...")
    theme_dir = os.path.join(base_dir, theme)
    os.makedirs(theme_dir, exist_ok=True)
    
    # 110 = General + Anime
    # atleast = 1920x1080 (PC high res)
    url = "https://wallhaven.cc/api/v1/search"
    params = {
        "q": query,
        "categories": "110",
        "purity": "100",
        "sorting": "random",
        "atleast": "1920x1080",
        "ratios": "16x9,16x10,21x9",
        "colors": color,
        "per_page": "10"
    }
    
    try:
        resp = requests.get(url, params=params)
        if resp.status_code == 429:
            print("Rate limited! Waiting 10 seconds...")
            time.sleep(10)
            resp = requests.get(url)
            
        json_data = resp.json()
        items = json_data.get("data", [])
        
        # If no results with color, fallback to query only without color constraint
        if not items:
            print(f"No color matches for {theme}, falling back to query only...")
            fallback_params = params.copy()
            del fallback_params["colors"]
            resp = requests.get(url, params=fallback_params)
            json_data = resp.json()
            items = json_data.get("data", [])
        
        if not items:
            print(f"Still no results for {theme}!")
            
        for i, item in enumerate(items):
            img_url = item["path"]
            ext = img_url.split(".")[-1]
            img_resp = requests.get(img_url)
            
            # Save the file
            file_path = os.path.join(theme_dir, f"aesthetic_{i+1}.{ext}")
            with open(file_path, "wb") as f:
                f.write(img_resp.content)
            time.sleep(1) # Be very nice to the API
    except Exception as e:
        print(f"Error fetching {theme}: {e}")
        
print("Finished fetching cool high-res aesthetic wallpapers!")
