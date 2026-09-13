#!/usr/bin/env python3
import sys
import json
import subprocess

def run_cmd(cmd):
    try:
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=8)
        return res.stdout.strip()
    except Exception:
        return ""

def ensure_wifi_unblocked():
    run_cmd(["rfkill", "unblock", "wifi"])
    run_cmd(["nmcli", "radio", "wifi", "on"])

def get_status():
    dev_output = run_cmd(["nmcli", "-t", "-f", "DEVICE,TYPE,STATE,CONNECTION", "dev"])
    wired_active = False
    wifi_active = False
    wired_conn = ""
    wifi_conn = ""
    active_type = "none"

    for line in dev_output.splitlines():
        parts = line.split(":")
        if len(parts) >= 4:
            dev, dev_type, state, conn = parts[0], parts[1], parts[2], parts[3]
            if dev_type == "ethernet" and state == "connected":
                wired_active = True
                wired_conn = conn or "Ethernet"
                if active_type == "none":
                    active_type = "wired"
            elif dev_type == "wifi" and state == "connected":
                wifi_active = True
                wifi_conn = conn or "Wi-Fi"
                active_type = "wifi"

    wifi_radio = run_cmd(["nmcli", "radio", "wifi"]) == "enabled"
    ip_output = run_cmd(["hostname", "-I"])
    ip = ip_output.split()[0] if ip_output else ""

    return {
        "wired_active": wired_active,
        "wifi_active": wifi_active,
        "wifi_radio": wifi_radio,
        "active_type": active_type,
        "wired_conn": wired_conn,
        "wifi_conn": wifi_conn,
        "ip": ip
    }

def get_wifi_list():
    ensure_wifi_unblocked()
    wifi_output = run_cmd(["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi", "list", "--rescan", "auto"])
    networks = []
    seen = set()
    for line in wifi_output.splitlines():
        parts = line.split(":")
        if len(parts) >= 4:
            in_use = (parts[0] == "*")
            ssid = parts[1].strip()
            signal = int(parts[2]) if parts[2].isdigit() else 0
            security = parts[3].strip()
            if ssid and ssid not in seen:
                seen.add(ssid)
                networks.append({
                    "in_use": in_use,
                    "ssid": ssid,
                    "signal": signal,
                    "security": security
                })
    return networks

def switch_wired():
    run_cmd(["nmcli", "device", "connect", "enp3s0"])
    return get_status()

def switch_wifi():
    ensure_wifi_unblocked()
    run_cmd(["nmcli", "device", "connect", "wlan0"])
    return get_status()

def connect_wifi(ssid):
    ensure_wifi_unblocked()
    # Try existing connection profile first
    res = run_cmd(["nmcli", "connection", "up", "id", ssid])
    if "successfully activated" not in res.lower():
        # Fallback to dev wifi connect
        run_cmd(["nmcli", "device", "wifi", "connect", ssid])
    return get_status()

def main():
    if len(sys.argv) < 2:
        print(json.dumps(get_status()))
        return

    arg = sys.argv[1]
    if arg == "--status":
        print(json.dumps(get_status()))
    elif arg == "--wifi-list":
        print(json.dumps(get_wifi_list()))
    elif arg == "--switch-wired":
        print(json.dumps(switch_wired()))
    elif arg == "--switch-wifi":
        print(json.dumps(switch_wifi()))
    elif arg == "--connect-wifi" and len(sys.argv) > 2:
        print(json.dumps(connect_wifi(sys.argv[2])))
    elif arg == "--toggle-wifi":
        curr = run_cmd(["nmcli", "radio", "wifi"])
        if curr == "enabled":
            run_cmd(["nmcli", "radio", "wifi", "off"])
        else:
            ensure_wifi_unblocked()
        print(json.dumps(get_status()))
    else:
        print(json.dumps(get_status()))

if __name__ == "__main__":
    main()
