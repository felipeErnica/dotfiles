#!/usr/bin/env python3
import subprocess
import sys
from pathlib import Path

CONFIG = Path.home() / ".config/rofi/wifi-menu.rasi"


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


def notify(title, message):
    run(f'notify-send "{title}" "{message}"', capture=False)


def get_wifi_list():
    """
    Returns a list of formatted Wi-Fi entries for rofi.
    """
    output = run("nmcli -t -f SECURITY,SSID device wifi list")
    entries = []

    for line in output.splitlines():
        security, ssid = (line.split(":", 1) + [""])[:2]

        if not ssid:
            continue

        if security and security != "--":
            icon = "󱚿"   # secured
        else:
            icon = "󰖩"   # open

        entries.append(f"{icon}  {ssid}")

    for entry in entries:
        if entries.count(entry) > 1:
            entries.remove(entry)

    return entries


def wifi_enabled():
    return "habilitado" in run("nmcli -fields WIFI g")


def rofi_menu(options):
    menu = "\n".join(options)
    return run(
        f'echo "{menu}" | rofi -dmenu -i '
        f'-config "{CONFIG}" -p " " -selected-row 1'
    )


def get_saved_connections():
    """
    Returns a set of saved connection names.
    """
    output = run("nmcli -t -f NAME connection show")
    return set(line.strip() for line in output.splitlines() if line.strip())


def get_password():
    return run(
        f'rofi -dmenu -password '
        f'-config "{CONFIG}" '
        f'-theme-str \''
        f'window {{ height: 47px; }} '
        f'wallbox {{ enabled: true; }} '
        f'prompt {{ enabled: false; }} '
        f'entry {{ placeholder: "Insira Senha"; }}\''
    )


# ------------------ main ------------------

notify("Wi-Fi", "Procurando redes disponíveis...")

wifi_list = get_wifi_list()
known_conns = get_saved_connections()

toggle = (
    "󰖪  Desabilitar Wi-Fi"
    if wifi_enabled()
    else "󱚽  Habilitar Wi-Fi"
)

chosen = rofi_menu([toggle, *wifi_list])

if not chosen:
    sys.exit(0)

# Toggle Wi-Fi
if chosen == "󱚽  Habilitar Wi-Fi":
    notify("Wi-Fi", "WiFi habilitado.")
    run("nmcli radio wifi on", capture=False)
    sys.exit(0)

if chosen == "󰖪  Desabilitar Wi-Fi":
    notify("Wi-Fi", "WiFi desabilitado.")
    run("nmcli radio wifi off", capture=False)
    sys.exit(0)

# Extract SSID
ssid = chosen[3:].strip()
success_msg = f'Conectado à "{ssid}".'

# Saved connection
if ssid in known_conns:
    result = run(f'nmcli connection up id "{ssid}"')
    if "sucesso" in result:
        notify("Conexão Estabelecida", success_msg)
        sys.exit(0)

# New connection
if chosen.startswith("󰖩"):
    result = run(f'nmcli device wifi connect "{ssid}"')
    if "sucesso" in result:
        notify("Conexão Estabelecida", success_msg)
    else:
        notify(
            "Falha ao Conectar",
            f'Não foi possível conectar à rede "{ssid}".',
        )
    sys.exit(0)

password = get_password()
if not password:
    notify("Conexão Cancelada", "Senha não fornecida.")
    sys.exit(0)

result = run(
    f'nmcli device wifi connect "{ssid}" password "{password}"'
)

if "sucesso" in result:
    notify("Conexão Estabelecida", success_msg)
else:
    notify(
        "Falha ao Conectar",
        f'Não foi possível conectar à rede "{ssid}". Verifique a senha.',
    )
