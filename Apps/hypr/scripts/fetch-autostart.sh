#!/usr/bin/env bash
FLAG="${XDG_RUNTIME_DIR:-/tmp}/hypr-layout-done"

# wait until the autostart script says the layout is final (max 30s)
for i in $(seq 300); do
  [ -e "$FLAG" ] && break
  sleep 0.1
done

# then wait until the window size is stable
prev=""
for i in $(seq 30); do
  cur=$(kitten icat --print-window-size 2>/dev/null)
  [ -n "$cur" ] && [ "$cur" = "$prev" ] && break
  prev=$cur
  sleep 0.15
done

reset
fastfetch -c ~/.config/fastfetch/nixos-01.jsonc
read -n 1 -s -r