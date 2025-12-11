#!/usr/bin/env bash

# Rofi configuration
config="$HOME/.config/rofi/wifi-menu.rasi"

notify-send "Wi-Fi" "Procurando redes disponíveis..."
# Get a list of available wifi connections and morph it into a nice-looking list
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | 
            sed 1d | 
            sed 's/  */ /g' | 
            sed -E "s/WPA*.?\S/󱚿 /g" | 
            sed "s/^--/󰖩 /g" | 
            sed "s/󱚿  󱚿/󱚿/g" | 
            sed "/--/d"
        )

connected=$(nmcli -fields WIFI g)
if [[ "$connected" =~ "habilitado" ]]; then
	toggle="󰖪  Desabilitar Wi-Fi"
elif [[ "$connected" =~ "desabilitado" ]]; then
	toggle="󱚽  Habilitar Wi-Fi"
fi

# Use rofi to select wifi network
chosen_network=$(echo -e "$toggle\n$wifi_list" | uniq -u | rofi -dmenu -i -config "$config" -p " " -selected-row 1)
# Get name of connection

if [ "$chosen_network" = "" ]; then
	exit
elif [ "$chosen_network" = "󱚽  Habilitar Wi-Fi" ]; then
    notify-send "Wi-Fi" "WiFi habilitado."
	nmcli radio wifi on
elif [ "$chosen_network" = "󰖪  Desabilitar Wi-Fi" ]; then
    notify-send "Wi-Fi" "WiFi desabilitado."
	nmcli radio wifi off
else
	# Message to show when connection is activated successfully
    chosen_id="${chosen_network:3}"
    chosen_id=$(echo "$chosen_id" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  	success_message="Conectado à \"$chosen_id\"."
	# Get saved connections
    saved_connections=$(nmcli -g NAME connection)
    if nmcli -g NAME,TYPE connection | grep -E 'wifi|wlan' | awk -F: '{print $1}' | grep -q "$chosen_id"; then
        # Connection is saved, try to connect
        if nmcli connection up id "$chosen_id" | grep -q "sucesso"; then
            notify-send "Conexão Estabelecida" "$success_message"
        else
            notify-send "Falha ao Conectar" "Não foi possível conectar à rede \"$chosen_id\"."
        fi

	else
        get_password() {
              rofi -dmenu -password \
                -config "${config}" \
                -theme-str "window { height: 47px; } wallbox { enabled: true; } prompt { enabled: false; } entry { placeholder: \"Insira Senha\"; }"
        }
		if [[ "$chosen_network" =~ "" ]]; then
            wifi_password=$(get_password)

            # Exit if password prompt was cancelled
            if [ -z "$wifi_password" ]; then
                notify-send "Conexão Cancelada" "Senha não fornecida."
                exit 0
            fi
		fi
        
        # Use a temporary variable for the command and check its status
        if nmcli device wifi connect "$chosen_id" password "$wifi_password" | grep -q "sucesso"; then
            notify-send "Conexão Estabelecida" "$success_message"
        else
            notify-send "Falha ao Conectar" "Não foi possível conectar à rede \"$chosen_id\". Verifique a senha."
        fi

    fi
fi
