#!/usr/bin/env bash
set -euo pipefail

SRC="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DATA="$HOME/Apps/Chromium"
CONF="$SRC/sites.conf"
THEME="$SRC/sidebar.rasi"
PROFILE="$DATA/profile"
ICONS="$DATA/icons"

mkdir -p "$ICONS"

trim() {
  local v="$1"
  v="${v#"${v%%[![:space:]]*}"}"
  v="${v%"${v##*[![:space:]]}"}"
  printf '%s' "$v"
}

# Colored rounded tile with the first letter, generated once and cached.
# To use a real logo, overwrite the PNG in ~/Apps/Chromium/icons/.
make_icon() {
  local f="$ICONS/$1.png"
  if [[ ! -f "$f" ]]; then
    magick -size 128x128 xc:none -fill "$2" \
      -draw "roundrectangle 0,0 127,127 28,28" \
      -gravity center -fill white -pointsize 68 \
      -annotate 0 "${1:0:1}" "$f" 2>/dev/null || f=""
  fi
  printf '%s' "$f"
}
names=(); urls=(); colors=(); icons=()
while IFS='|' read -r name url color icon || [[ -n "${name:-}" ]]; do
  name="$(trim "${name:-}")"; url="$(trim "${url:-}")"
  color="$(trim "${color:-}")"; icon="$(trim "${icon:-}")"
  if [[ -z "$name" || "${name:0:1}" == "#" || -z "$url" ]]; then continue; fi
  names+=("$name"); urls+=("$url"); colors+=("${color:-#444444}"); icons+=("$icon")
done < "$CONF"

choice="$(
  for i in "${!names[@]}"; do
    ic="${icons[$i]}"
    [[ -z "$ic" ]] && ic="$(make_icon "${names[$i]}" "${colors[$i]}")"
    printf '%s\0icon\x1f%s\n' "${names[$i]}" "$ic"
  done | rofi -dmenu -i -show-icons -format i -p "Apps" -theme "$THEME"
)" || exit 0


exec chromium \
  --user-data-dir="$PROFILE" \
  --no-first-run \
  --no-default-browser-check \
  --ozone-platform-hint=auto \
  --enable-features=WebNotifications \
  --app="${urls[$choice]}"
