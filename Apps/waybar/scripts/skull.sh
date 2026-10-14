#!/usr/bin/env bash
DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-updates"
mkdir -p "$DIR"

show() {
  # new waybar process -> run one check in the background
  pid=$(pgrep -xo waybar)
  if [ "$(cat "$DIR/pid" 2>/dev/null)" != "$pid" ]; then
    echo "$pid" > "$DIR/pid"
    touch "$DIR/scanning"
    setsid bash "$0" check >/dev/null 2>&1 &
  fi

  if [ -f "$DIR/scanning" ]; then
    printf '{"text":"<span alpha=\\"50%%\\">󰚰</span>","tooltip":"Checking for updates...","class":"scanning"}\n'
    return
  fi

  n=$(cat "$DIR/count" 2>/dev/null || echo 0)
  case "$n" in
    0)
      printf '{"text":"󰚰","tooltip":"System is up to date\\nLeft click: rescan","class":"uptodate"}\n' ;;
    '?')
      printf '{"text":"<span alpha=\\"50%%\\">󰚰</span>","tooltip":"Check failed\\nLeft click: retry","class":"failed"}\n' ;;
    *)
      printf '{"text":"󰚰 %s","tooltip":"%s flake inputs have updates\\nLeft click: rescan\\nRight click: update","class":"pending"}\n' "$n" "$n" ;;
  esac
}

check() {
  exec 9>"$DIR/lock"