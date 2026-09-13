import subprocess
import json
import sys
import os

def get_clipboard(limit=25):
    try:
        res = subprocess.run(["cliphist", "list"], capture_output=True, text=True)
        if res.returncode != 0:
            return []
        
        items = []
        for line in res.stdout.strip().split('\n'):
            if not line:
                continue
            parts = line.split('\t', 1)
            if len(parts) == 2:
                cid, content = parts
                item_type = "text"
                image_path = ""
                if content.startswith("[[ binary data") and "png" in content:
                    item_type = "image"
                    image_path = f"/tmp/quickshell_clip_{cid}.png"
                    if not os.path.exists(image_path):
                        # Decode the image to a temp file
                        try:
                            with open(image_path, "wb") as f:
                                subprocess.run(["cliphist", "decode", cid], stdout=f)
                        except Exception:
                            pass

                items.append({
                    "id": cid, 
                    "content": content, 
                    "type": item_type,
                    "image_path": image_path
                })
                if len(items) >= limit:
                    break
        return items
    except Exception:
        return []

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "decode":
        cid = sys.argv[2]
        # Decode and copy to clipboard
        p1 = subprocess.Popen(["cliphist", "decode", cid], stdout=subprocess.PIPE)
        # determine type from id
        # cliphist list again, find id
        res = subprocess.run(["cliphist", "list"], capture_output=True, text=True)
        is_img = False
        for line in res.stdout.strip().split('\n'):
            if line.startswith(cid + "\t"):
                if "[[ binary data" in line and "png" in line:
                    is_img = True
                break
        if is_img:
            subprocess.run(["wl-copy", "--type", "image/png"], stdin=p1.stdout)
        else:
            subprocess.run(["wl-copy"], stdin=p1.stdout)
        p1.stdout.close()
        p1.wait()
        sys.exit(0)
    
    print(json.dumps(get_clipboard(), ensure_ascii=False))
