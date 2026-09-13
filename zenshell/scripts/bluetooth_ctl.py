#!/usr/bin/env python3
import sys
import json
import subprocess
import re
import time

def run_cmd(cmd):
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=5)
        return res.stdout.strip()
    except Exception:
        return ""

def get_status():
    show_out = run_cmd(["bluetoothctl", "show"])
    powered = "Powered: yes" in show_out
    return {"powered": powered}

def get_devices():
    devs_out = run_cmd(["bluetoothctl", "devices"])
    devices = []
    for line in devs_out.splitlines():
        parts = line.split(" ", 2)
        if len(parts) >= 3 and parts[0] == "Device":
            mac = parts[1]
            name = parts[2]
            info = run_cmd(["bluetoothctl", "info", mac])
            connected = "Connected: yes" in info
            paired = "Paired: yes" in info
            icon_match = re.search(r"Icon:\s+(\S+)", info)
            icon = icon_match.group(1) if icon_match else "generic"
            devices.append({
                "mac": mac,
                "name": name,
                "connected": connected,
                "paired": paired,
                "icon": icon
            })
    return devices

def ensure_power_on():
    run_cmd(["rfkill", "unblock", "bluetooth"])
    time.sleep(0.3)
    run_cmd(["bluetoothctl", "power", "on"])

def toggle_power():
    curr = get_status()
    if curr["powered"]:
        run_cmd(["bluetoothctl", "power", "off"])
    else:
        ensure_power_on()
    return get_status()

def toggle_connect(mac):
    ensure_power_on()
    info = run_cmd(["bluetoothctl", "info", mac])
    if "Connected: yes" in info:
        run_cmd(["bluetoothctl", "disconnect", mac])
    else:
        run_cmd(["bluetoothctl", "connect", mac])
    return get_devices()

def main():
    if len(sys.argv) < 2:
        print(json.dumps(get_status()))
        return

    arg = sys.argv[1]
    if arg == "--status":
        print(json.dumps(get_status()))
    elif arg == "--devices":
        print(json.dumps(get_devices()))
    elif arg == "--toggle":
        print(json.dumps(toggle_power()))
    elif arg == "--connect" and len(sys.argv) > 2:
        print(json.dumps(toggle_connect(sys.argv[2])))
    else:
        print(json.dumps(get_status()))

if __name__ == "__main__":
    main()
