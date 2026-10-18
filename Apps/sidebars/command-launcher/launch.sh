#!/usr/bin/env bash

if pgrep -x rofi >/dev/null; then
  pkill -x rofi
  exit 0
fi

set -euo pipefail

SRC="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CONF="$SRC/commands.conf"
THEME="$SRC/sidebar-right.rasi"
ICONS="$SRC/icons"

mkdir -p "$ICONS"

trim() {
    local v="$1"
    v="${v#"${v%%[![:space:]]*}"}"
    v="${v%"${v##*[![:space:]]}"}"
    printf '%s' "$v"
}

names=()
cmds=()
icons=()

while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(trim "$line")"
    [[ -n "$line" && "${line:0:1}" != "#" ]] || continue
    [[ "$line" == *"::"* ]] || continue

    name="$(trim "${line%%::*}")"
    rest="${line#*::}"

    if [[ "$rest" == *"::"* ]]; then
        cmd="$(trim "${rest%%::*}")"
        icon="$(trim "${rest#*::}")"
    else
        cmd="$(trim "$rest")"
        icon=""
    fi

    [[ -n "$name" && -n "$cmd" ]] || continue
    names+=("$name")
    cmds+=("$cmd")
    icons+=("$icon")
done < "$CONF"

if ((${#names[@]} == 0)); then
    printf 'No commands found in %s\n' "$CONF" >&2
    exit 1
fi

choice="$(
    for i in "${!names[@]}"; do
        icon="${icons[$i]}"
        if [[ -n "$icon" && -f "$ICONS/$icon.png" ]]; then
            printf '%s\0icon\x1f%s\n' "${names[$i]}" "$ICONS/$icon.png"
        elif [[ -n "$icon" ]]; then
            printf '%s\0icon\x1f%s\n' "${names[$i]}" "$icon"
        else
            printf '%s\n' "${names[$i]}"
        fi
    done |
        rofi -dmenu -i -show-icons -format i -p "Run" -theme "$THEME"
)" || exit 0

[[ "$choice" =~ ^[0-9]+$ ]] || exit 0
(( choice < ${#cmds[@]} )) || exit 0

# run detached so it survives rofi/this script exiting
setsid -f bash -c "${cmds[$choice]}" >/dev/null 2>&1