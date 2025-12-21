#!/usr/bin/env python3

import time
import subprocess
from pathlib import Path

# Battery percentage thresholds
notify_levels = [3, 5, 10, 15]

power_supply_path = Path("/sys/class/power_supply")

# Find first BAT device
bat_devices_path = power_supply_path.iterdir()
bat_devices = []

for file in bat_devices_path:
    if file.name.startswith("BAT"):
        bat_devices.insert(0, file)

if not bat_devices:
    raise RuntimeError("Nenhuma bateria encontrada!")

BAT = bat_devices[0]
capacity_file = BAT / "capacity"
img_path = str(Path.home() / ".config/hypr/scripts/low_battery_icon.png")
last_notify = 100

while True:
    try:
        bat_lvl = int(capacity_file.read_text().strip())
    except Exception as e:
        print(f"Failed to read battery level: {e}")
        time.sleep(60)
        continue

    # Reset notification state if battery increased
    if bat_lvl > last_notify:
        last_notify = bat_lvl

    for low_level in notify_levels:
        if bat_lvl <= low_level and low_level <= last_notify:
            subprocess.run([
                "notify-send",
                "-u", "critical",
                "ATENÇÃO!",
                f"Bateria em estado crítico: {bat_lvl}%",
                "-i", img_path
            ], check=False)

            subprocess.run([
                "paplay",
                "/usr/share/sounds/freedesktop/stereo/service-logout.oga"
            ], check=False)

            last_notify = low_level - 1
            break  # prevents multiple notifications in the same loop

    time.sleep(60)
