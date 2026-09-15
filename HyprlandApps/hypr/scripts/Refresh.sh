#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Scripts for refreshing ags, rofi, swaync, wallust

SCRIPTSDIR=${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts
UserScripts=${XDG_CONFIG_HOME:-$HOME/.config}/hypr/UserScripts
QS_TEXTINPUT_LOG_RULE="qt.qpa.wayland.textinput.warning=false"

# Define file_exists function
file_exists() {
  if [ -e "$1" ]; then
    return 0 # File exists
  else
    return 1 # File does not exist
  fi
}

# Kill already running processes (exclude swaync to avoid double reloads)
_ps=(rofi ags)
for _prs in "${_ps[@]}"; do
  if pidof "${_prs}" >/dev/null; then
    pkill "${_prs}"
  fi
done


# quit ags & relaunch ags
if command -v ags >/dev/null 2>&1; then
  ags -q >/dev/null 2>&1 || true
  ags >/dev/null 2>&1 &
fi

# quit quickshell & relaunch quickshell
pkill qs && qs --log-rules "$QS_TEXTINPUT_LOG_RULE" &

# some process to kill (exclude swaync to avoid restart loops)
for pid in $(pidof rofi ags swaybg); do
  kill -SIGUSR1 "$pid"
  sleep 0.1
done

is_swaync_systemd() {
  command -v systemctl >/dev/null 2>&1 || return 1
  systemctl --user cat swaync.service >/dev/null 2>&1 || return 1
  local enabled_state
  enabled_state="$(systemctl --user is-enabled swaync.service 2>/dev/null || true)"
  case "$enabled_state" in
    enabled|static) return 0 ;;
  esac
  systemctl --user is-active --quiet swaync.service 2>/dev/null && return 0
  return 1
}


# relaunch swaync if not running, then reload config and CSS in-place
if is_swaync_systemd; then
  if ! systemctl --user is-active --quiet swaync.service 2>/dev/null; then
    systemctl --user start swaync.service >/dev/null 2>&1 &
  fi
else
  sleep 0.3
  if ! pidof swaync >/dev/null 2>&1; then
    swaync >/dev/null 2>&1 &
  fi
fi
# reload swaync config and CSS (asynchronous to prevent DBus timeout delays)
(swaync-client -R -rs --skip-wait >/dev/null 2>&1 &)

# reload / restart nwg-dock-hyprland if running
if pgrep -x "nwg-dock-hyprla" >/dev/null 2>&1 || pgrep -x "nwg-dock-hyprland" >/dev/null 2>&1 || pgrep -f "nwg-dock-hyprland" >/dev/null 2>&1; then
  "${SCRIPTSDIR}/Dock.sh" --restart >/dev/null 2>&1 &
fi

# Relaunching rainbow borders based on selected mode
sleep 1
rainbow_mode_file="${UserScripts}/rainbow-borders.mode"
rainbow_mode=""
if [[ -f "$rainbow_mode_file" ]]; then
  rainbow_mode="$(tr -d '[:space:]' <"$rainbow_mode_file")"
fi
if [[ "$rainbow_mode" == "low_cpu" ]]; then
  pkill -f 'RainbowBorders-low-cpu\.sh' >/dev/null 2>&1 || true
  rm -f /tmp/hypr-rainbowborders.lock >/dev/null 2>&1 || true
  if file_exists "${UserScripts}/RainbowBorders-low-cpu.sh"; then
    "${UserScripts}/RainbowBorders-low-cpu.sh" >/dev/null 2>&1 &
  fi
elif file_exists "${UserScripts}/RainbowBorders.sh"; then
  "${UserScripts}/RainbowBorders.sh" &
fi

exit 0
