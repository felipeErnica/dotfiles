#!/usr/bin/env python3
import subprocess
import json


def run(cmd, capture=True):
    if capture:
        return subprocess.run(
            cmd,
            shell=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            timeout=10,
        ).stdout.strip()
    else:
        subprocess.run(cmd, shell=True, timeout=10)


def vpn_status():
    status = run("nordvpn status | sed -n 1,4p")
    disconnected = {
        "alt": "disconnected",
        "class": "disconnected",
        "tooltip": "VPN desativada"
    }

    if not status:
        return disconnected

    status_dict = {}
    for line in status.splitlines():
        clean_line = line.replace("-", "").replace("/", "").strip()

        if ":" in clean_line:
            key, value = clean_line.split(":", 1)
            json_key = key.strip().lower().replace(" ", "_")
            status_dict[json_key] = value.strip()

    if not status_dict or status_dict.get("status") == "Disconnected":
        return disconnected

    server = status_dict.get("server")
    ip = status_dict.get("ip")

    connected = {
        "alt": "connected",
        "class": "connected",
        "tooltip": f"Servidor:  {server}\rIP:  {ip}"
    }

    return connected


status = vpn_status()
status_json = json.dumps(status)
print(status_json, flush=True)
