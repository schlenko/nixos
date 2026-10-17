#!/usr/bin/env bash
DIR="${XDG_CACHE_HOME:-$HOME/.cache}/waybar-updates"
mkdir -p "$DIR"

show() {
  # new waybar process -> run one check in the background
  pid=$(pgrep -xo waybar)
  if [ "$(cat "$DIR/pid" 2>/dev/null)" != "$pid" ]; then
    echo "$pid" > "$DIR/pid"
    touch "$DIR/scanning"
    setsid bash "$0" check auto >/dev/null 2>&1 &
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
      tip=$(awk -F'\t' '{printf "%s: %s → %s\\n", $1, $2, $3}' "$DIR/list" 2>/dev/null)
      printf '{"text":"󰚰 %s","tooltip":"%s flake inputs have updates\\n%s\\nLeft click: rescan\\nRight click: update","class":"pending"}\n' "$n" "$n" "$tip" ;;
  esac
}

esc() { sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'; }

notify() {
  notify-send -a updates "$@"
}

check() {
  mode="${1:-manual}"   # "auto" = started with waybar, "manual" = clicked

  exec 9>"$DIR/lock"
  flock -n 9 || exit 0   # already running

  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"; rm -f "$DIR/scanning"' EXIT

  # show the dim "scanning" state right away
  touch "$DIR/scanning"
  pkill -RTMIN+8 waybar

  cd /etc/nixos || exit 0

  : > "$tmp/list"

  if ! nm-online -q -t 60; then
    echo "?" > "$DIR/count"
    [ "$mode" = manual ] && notify -u critical "󰅚 Update check failed" "No network connection"
  elif nix flake update --output-lock-file "$tmp/new.lock" >/dev/null 2>&1; then
    # name / old rev / new rev / date, one line per changed input
    jq -nr --slurpfile o flake.lock --slurpfile n "$tmp/new.lock" '
      $o[0] as $O | $n[0] as $N
      | ($N.nodes.root.inputs | to_entries
         | map(select(.value | type == "string") | {key: .value, value: .key})
         | from_entries) as $lbl
      | $N.nodes | to_entries[]
      | select(.value.locked.rev != null)
      | . as $e
      | ($O.nodes[$e.key].locked.rev // "") as $old
      | select($old != $e.value.locked.rev)
      | [ ($lbl[$e.key] // $e.key),
          ($old[0:7]),
          ($e.value.locked.rev[0:7]),
          ($e.value.locked.lastModified | strftime("%Y-%m-%d")) ]
      | @tsv' > "$tmp/list" 2>/dev/null

    count=$(wc -l < "$tmp/list")
    echo "$count" > "$DIR/count"
    cp "$tmp/list" "$DIR/list"

    if [ "$count" -eq 0 ]; then
      [ "$mode" = manual ] && notify "󰸞 Up to date" "No updates available"
    else
      # one message per package
      while IFS=$'\t' read -r name old new date; do
        notify "󰚰 $(printf '%s' "$name" | esc)" "${old:-new} → $new  ($date)"
      done < "$tmp/list"
    fi
  else
    echo "?" > "$DIR/count"
    [ "$mode" = manual ] && notify -u critical "󰅚 Update check failed" "nix flake update returned an error"
  fi

  # clear the scanning marker, then refresh waybar with the result
  rm -f "$DIR/scanning"
  pkill -RTMIN+8 waybar
}

case "${1:-show}" in
  check) check "${2:-manual}" ;;
  *) show ;;
esac