
#!/usr/bin/env bash

prev=""

nmcli monitor | while IFS= read -r line; do
    case "$line" in
        *"connected"*)
            notify-sound device-added
            notify-send -a wifi "󰖩 Wi-Fi connected" "$line"
            ;;
        *"disconnected"*)
            notify-sound device-removed
            notify-send -a wifi "󰖪 Wi-Fi disconnected" "$line"
            ;;
    esac
done
