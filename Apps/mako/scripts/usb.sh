#!/usr/bin/env bash
# usage: usb-notify usb    -> plug/unplug of USB and USB-C devices
#        usb-notify mount  -> mount/unmount events

esc() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

declare -A p

# ---------------- USB / USB-C plug events ----------------
flush() {
  [ -n "${p[ACTION]:-}" ] || return 0
  local action="${p[ACTION]}" sub="${p[SUBSYSTEM]:-}" type="${p[DEVTYPE]:-}"
  local name vendor body

  case "$sub:$type" in
    usb:usb_device)
      # skip the virtual root hubs (Linux Foundation)
      [ "${p[ID_VENDOR_ID]:-}" = "1d6b" ] && return 0

      name="${p[ID_MODEL_FROM_DATABASE]:-${p[ID_MODEL]:-USB device}}"
      vendor="${p[ID_VENDOR_FROM_DATABASE]:-${p[ID_VENDOR]:-}}"
      name="${name//_/ }"
      vendor="${vendor//_/ }"
      body="$(printf '%s %s' "$vendor" "$name" | esc)"

      case "$action" in
        add)
          notify-sound device-added
          notify-send -a usb "$(printf '\uf287') USB device connected" "$body" ;;
        remove)
          notify-sound device-removed
          notify-send -a usb "$(printf '\uf287') USB device removed" "$body" ;;
      esac
      ;;

    typec:typec_partner)
      case "$action" in
        add)
          notify-sound device-added
          notify-send -a usb "$(printf '\uf1e6') USB-C connected" "Partner device attached" ;;
        remove)
          notify-sound device-removed
          notify-send -a usb "$(printf '\uf1e6') USB-C disconnected" "Partner device removed" ;;
      esac
      ;;
  esac
}

usb_mode() {
  while IFS= read -r line; do
    if [ -z "$line" ]; then
      flush
      p=()
      continue
    fi
    case "$line" in
      *=*) p[${line%%=*}]=${line#*=} ;;
    esac
  done < <(udevadm monitor --udev --property \
             --subsystem-match=usb --subsystem-match=typec)
}

# ---------------- mount / unmount events ----------------
mount_mode() {
  findmnt --poll --real -n -o ACTION,FSTYPE,SOURCE,TARGET |
  while read -r action fstype source target; do
    # only real block devices, no bind mounts / loop devices / system mounts
    case "$source" in /dev/loop*|*"["*) continue ;; /dev/*) ;; *) continue ;; esac
    case "$target" in /|/boot|/nix/*|/var/lib/docker/*) continue ;; esac

    dev_esc="$(printf '%s' "$source" | esc)"
    tgt_esc="$(printf '%s' "$target" | esc)"

    case "$action" in
      mount)
        notify-send -a mount "$(printf '\uf0a0') Mounted" \
          "$tgt_esc\n$dev_esc · $fstype" ;;
      umount)
        notify-send -a mount "$(printf '\uf052') Unmounted" \
          "$tgt_esc\n$dev_esc" ;;
    esac
  done
}

case "${1:-usb}" in
  usb)   usb_mode ;;
  mount) mount_mode ;;
  *)     echo "usage: usb-notify [usb|mount]" >&2; exit 1 ;;
esac