#!/usr/bin/env bash

# Rofi configuration
config="$HOME/.config/rofi/wifi-menu.rasi"

# Init notification
notify-send "Wi-Fi" "Procurando redes disponíveis..."

while true; do
    
  # Get list of available Wi-Fi networks and apply formatting
  wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list |
    sed 1d |
    sed 's/  */ /g' |
    sed -E "s/WPA*.?\S/ 󰤪 /g" |
    sed "s/^--/ 󱛎 /g" |
    sed "s/ 󰤪   󰤪/ 󰤪/g" |
    sed "/--/d")

  # Check current Wi-Fi status (enabled/disabled)
  wifi_status=$(nmcli -fields WIFI g)

  # Display the menu based on Wi-Fi status
  if [[ "$wifi_status" =~ "habilitado" ]]; then
      selected_option=$(echo -e "   Rescanear\n   Inserção Manual\n 󰤭  Desabilitar Wi-Fi\n$wifi_list" |
      rofi -dmenu -i -selected-row 2 -config "${config}" -theme-str "window { height: 515px; }")
  elif [[ "$wifi_status" =~ "desabilitado" ]]; then
      selected_option=$(echo -e " 󰤨  Habilitar Wi-Fi" |
      rofi -dmenu -i -config "${config}" -theme-str "window { height: 47px; }")
  fi

  # Extract selected SSID
  read -r selected_ssid <<<"${selected_option:4}"

  # Perform actions based on the selected option
  if [ -z "$selected_option" ]; then
    exit

  elif [ "$selected_option" = " 󰤨  Habilitar Wi-Fi" ]; then
    notify-send "Wi-Fi" "Habilitado"
    notify-send "Wi-Fi" "Buscando redes..."
    nmcli radio wifi on
    nmcli device wifi rescan
    sleep 3

  elif [ "$selected_option" = " 󰤭  Desabilitar Wi-Fi" ]; then
    notify-send "Wi-Fi" "Desabilitado"
    nmcli radio wifi off
    sleep 1

  elif [ "$selected_option" = "   Inserção Manual" ]; then
    notify-send "Wi-Fi" "Inserir SSID e senha manualmente..."

    # Prompt for manual SSID
    manual_ssid=$(rofi -dmenu \
      -config "${config}" \
      -theme-str "window { height: 47px; } wallbox { enabled: true; } entry { placeholder: \"Insira o SSID\"; }")

    if [ -z "$manual_ssid" ]; then
      exit
    fi

    # Prompt for password using reusable function
    get_password() {
      rofi -dmenu -password \
        -theme-str "window { height: 47px; } wallbox { enabled: true; } entry { placeholder: \"Insira Senha\"; }"
        # -config "${config}" \
    }

    manual_password=$(get_password)

    if [ -z "$manual_password" ]; then
      nmcli device wifi connect "$manual_ssid"
    else
      nmcli device wifi connect "$manual_ssid" password "$manual_password"
    fi

  elif [ "$selected_option" = "   Rescanear" ]; then
    notify-send "Wi-Fi" "Buscando redes..."
    nmcli device wifi rescan
    sleep 3
    notify-send "Wi-Fi" "Busca completa!"

  else
    # Notify when connection is activated successfully
    connected_notif="Conectado à \"$selected_ssid\"."

    # Get saved connections
    saved_connections=$(nmcli -g NAME connection)

    if echo "$saved_connections" | grep -qw "$selected_ssid"; then
      nmcli connection up id "$selected_ssid" |
        grep "successfully" &&
        notify-send "Conexão estabelecida!" "$connected_notif"
    else
      # Handle secure network connection
      wifi_password=$(get_password)

      nmcli device wifi connect "$selected_ssid" password "$wifi_password" |
        grep "successfully" &&
        notify-send "Wi-Fi" "$connected_notif"
    fi
  fi
done
