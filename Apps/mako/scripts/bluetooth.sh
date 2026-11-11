
#!/usr/bin/env bash

# Bluetooth event notifications through bluetoothctl

bluetoothctl monitor | while IFS= read -r line; do
    case "$line" in
        *"Powered: yes"*)
            notify-sound device-added
            notify-send -a bluetooth "󰂯 Bluetooth enabled" "Bluetooth adapter powered on"
            ;;
        *"Powered: no"*)
            notify-sound device-removed
            notify-send -a bluetooth "󰂲 Bluetooth disabled" "Bluetooth adapter powered off"
            ;;
        *"Connected: yes"*)
            notify-sound device-added
            notify-send -a bluetooth "󰂱 Bluetooth connected" "$line"
            ;;
        *"Connected: no"*)
            notify-sound device-removed
            notify-send -a bluetooth "󰂲 Bluetooth disconnected" "$line"
            ;;
    esac
done
