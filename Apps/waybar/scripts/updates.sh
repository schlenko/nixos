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
  flock -n 9 || exit 0   # already running

  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"; rm -f "$DIR/scanning"' EXIT

  # show the dim "scanning" state right away
  touch "$DIR/scanning"
  pkill -RTMIN+8 waybar

  cd /etc/nixos || exit 0

  if ! nm-online -q -t 60; then
    echo "?" > "$DIR/count"
  elif nix flake update --output-lock-file "$tmp/new.lock" >/dev/null 2>&1; then
    if diff -q flake.lock "$tmp/new.lock" >/dev/null; then
      echo 0 > "$DIR/count"
    else
      diff <(grep '"rev"' flake.lock) <(grep '"rev"' "$tmp/new.lock") | grep -c '^>' > "$DIR/count"
    fi
  else
    echo "?" > "$DIR/count"
  fi

  # clear the scanning marker, then refresh waybar with the result
  rm -f "$DIR/scanning"
  pkill -RTMIN+8 waybar
}

case "${1:-show}" in
  check) check ;;
  *) show ;;
esac