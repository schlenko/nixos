#!/usr/bin/env bash

if pgrep -x rofi >/dev/null; then
  pkill -x rofi
  exit 0
fi

set -euo pipefail

SRC="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
DATA="$HOME/Apps/Chromium"
CONF="$SRC/sites.conf"
THEME="$SRC/sidebar.rasi"
PROFILE="$DATA/profile"
ICONS="$SRC/icons"

mkdir -p "$ICONS" "$DATA" "$PROFILE"

trim() {
    local v="$1"
    v="${v#"${v%%[![:space:]]*}"}"
    v="${v%"${v##*[![:space:]]}"}"
    printf '%s' "$v"
}

names=()
urls=()
colors=()
custom_icons=()

# Read the app configuration.
while IFS='|' read -r name url color icon || [[ -n "${name:-}" ]]; do
    name="$(trim "${name:-}")"
    url="$(trim "${url:-}")"
    color="$(trim "${color:-}")"
    icon="$(trim "${icon:-}")"

    # Skip comments and incomplete entries.
    [[ -n "$name" && "${name:0:1}" != "#" && -n "$url" ]] || continue

    names+=("$name")
    urls+=("$url")
    colors+=("${color:-#444444}")
    custom_icons+=("$icon")
done < "$CONF"

if ((${#names[@]} == 0)); then
    printf 'No applications found in %s\n' "$CONF" >&2
    exit 1
fi

# Display the launcher.
choice="$(
    for i in "${!names[@]}"; do
        name="${names[$i]}"
        icon="${custom_icons[$i]}"

        # Priority 1: manually selected local icon.
        if [[ -n "$icon" && -f "$ICONS/$icon.png" ]]; then
            printf '%s\0icon\x1f%s\n' \
                "$name" "$ICONS/$icon.png"

        # Priority 2: configured system icon theme (Papirus).
        elif [[ -n "$icon" ]]; then
            printf '%s\0icon\x1f%s\n' \
                "$name" "$icon"

        # Priority 3: let Rofi display the entry without an icon.
        else
            printf '%s\n' "$name"
        fi
    done |
        rofi -dmenu \
            -i \
            -show-icons \
            -format i \
            -p "Apps" \
            -theme "$THEME"
)" || exit 0

# Validate the selected index.
[[ "$choice" =~ ^[0-9]+$ ]] || exit 0
(( choice < ${#urls[@]} )) || exit 0

# Launch the selected website in its Chromium app window.
exec chromium \
    --user-data-dir="$PROFILE" \
    --no-first-run \
    --no-default-browser-check \
    --ozone-platform-hint=auto \
    --enable-features=WebNotifications \
    --app="${urls[$choice]}"
