#!/usr/bin/env bash
BAT=/sys/class/power_supply/BAT1

notify() {
  notify-send -a battery -h string:x-canonical-private-synchronous:battery "$@"
}

prev=$(cat "$BAT/status")
level=100   # lowest threshold already announced during this discharge

check() {
  local cur pct
  cur=$(cat "$BAT/status")
  pct=$(cat "$BAT/capacity")

  # --- plug / unplug ---
  if [ "$cur" != "$prev" ]; then
    case "$cur" in
      Charging)
        notify-sound power-plug
        notify "󰂄 Charging started" "Battery at ${pct}%"
        ;;
      Discharging)
        notify-sound power-unplug
        notify "󰁹 Charger unplugged" "Battery at ${pct}%"
        ;;
      Full)
        notify-sound completion-success
        notify "󰁹 Fully charged"
        ;;
    esac
    prev=$cur
  fi

  # --- low battery levels (once per discharge) ---
  if [ "$cur" = "Discharging" ]; then
    if [ "$pct" -le 5 ] && [ "$level" -gt 5 ]; then
      level=5
      notify-sound dialog-warning
      notify -u critical "󰂎 Battery critical · ${pct}%" "Plug in the charger NOW"
    elif [ "$pct" -le 10 ] && [ "$level" -gt 10 ]; then
      level=10
      notify-sound dialog-warning
      notify -u critical "󰁺 Battery very low · ${pct}%" "Plug in the charger"
    elif [ "$pct" -le 30 ] && [ "$level" -gt 30 ]; then
      level=30
      notify-sound battery-caution
      notify "󰁼 Battery low · ${pct}%" "Consider plugging in"
    fi
  else
    level=100
  fi
}

while read -r _; do
  check
done < <(upower --monitor)