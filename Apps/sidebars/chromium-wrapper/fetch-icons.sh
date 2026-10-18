#!/usr/bin/env bash
set -uo pipefail

SRC="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
CONF="$SRC/sites.conf"
FETCHED="$SRC/icons-fetched"

mkdir -p "$FETCHED"

trim() {
    local v="$1"
    v="${v#"${v%%[![:space:]]*}"}"
    v="${v%"${v##*[![:space:]]}"}"
    printf '%s' "$v"
}

download_icon() {
    local url="$1"
    local output="$2"
    local raw="${output}.download"

    if curl -fsSL --location \
        --connect-timeout 5 \
        --max-time 15 \
        --max-filesize 5242880 \
        -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/131 Safari/537.36" \
        "$url" -o "$raw" 2>/dev/null &&
        [[ -s "$raw" ]] &&
        magick identify "$raw" >/dev/null 2>&1 &&
        magick "$raw" -background none -thumbnail '256x256>' \
            -strip "PNG:$output" 2>/dev/null &&
        [[ -s "$output" ]]; then
        rm -f "$raw"
        return 0
    fi

    rm -f "$raw" "$output"
    return 1
}

fetch_site() {
    local name="$1"
    local url="$2"
    local origin domain safe_name html_file
    local candidate count=0 saved=0
    local output stem
    local -a candidates=()
    local -A seen=()

    safe_name="$(printf '%s' "$name" |
        tr -cs '[:alnum:]_.-' '_')"

    # Determine the origin without query strings or paths.
    origin="$(python3 -c '
import sys
from urllib.parse import urlsplit
u = urlsplit(sys.argv[1])
print(f"{u.scheme}://{u.netloc}")
' "$url")" || return 0

    domain="${origin#*://}"
    domain="${domain%%:*}"

    printf '\n[%s] %s\n' "$name" "$url"

    candidates+=(
        "$origin/favicon.ico"
        "$origin/favicon.png"
        "$origin/favicon.svg"
        "$origin/favicon.gif"
        "$origin/favicon.jpg"
        "$origin/favicon.jpeg"
        "$origin/apple-touch-icon.png"
        "$origin/apple-touch-icon-precomposed.png"
        "$origin/apple-touch-icon-180x180.png"
        "$origin/android-chrome-192x192.png"
        "$origin/android-chrome-512x512.png"
        "https://$domain/favicon.ico"
        "https://$domain/favicon.png"
        "https://$domain/favicon.svg"
        "https://$domain/apple-touch-icon.png"
        "https://www.$domain/favicon.ico"
        "http://$domain/favicon.ico"
        "https://icons.duckduckgo.com/ip3/$domain.ico"
        "https://favicon.im/$domain?larger=true"
        "https://www.google.com/s2/favicons?domain=$domain&sz=256"
    )

    if [[ "$domain" == "web.whatsapp.com" ]]; then
        candidates+=(
            "https://web.whatsapp.com/favicon/1x/favicon.png"
        )
    fi

    # Discover icon URLs from the site's HTML.
    html_file="$(mktemp)"

    if curl -fsSL --location \
        --connect-timeout 5 --max-time 15 \
        -A "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/131 Safari/537.36" \
        "$url" -o "$html_file" 2>/dev/null; then

        while IFS= read -r candidate; do
            [[ -n "$candidate" ]] && candidates+=("$candidate")
        done < <(
            python3 - "$url" "$html_file" <<'PY'
import sys
from html.parser import HTMLParser
from urllib.parse import urljoin

page_url, filename = sys.argv[1:3]

class IconParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        rel = attrs.get("rel", "").lower().split()
        href = attrs.get("href", "")

        if tag == "link" and href and (
            "icon" in rel
            or "shortcut" in rel
            or "apple-touch-icon" in rel
            or "mask-icon" in rel
        ):
            print(urljoin(page_url, href))

with open(filename, encoding="utf-8", errors="replace") as f:
    parser = IconParser()
    parser.feed(f.read())
PY
        )
    fi

    rm -f "$html_file"

    # Number from existing files so previous results are preserved.
    for candidate in "${candidates[@]}"; do
        [[ -n "$candidate" ]] || continue
        [[ -z "${seen[$candidate]+x}" ]] || continue
        seen["$candidate"]=1
        count=$((count + 1))

        stem="$FETCHED/${safe_name}_${count}"
        output="${stem}.png"

        # Never overwrite anything from a previous run.
        while [[ -e "$output" ]]; do
            count=$((count + 1))
            stem="$FETCHED/${safe_name}_${count}"
            output="${stem}.png"
        done

        if download_icon "$candidate" "$output"; then
            saved=$((saved + 1))
            printf '  [+] %s\n' "$output"
        fi
    done

    printf '  Tried: %d | Saved: %d\n' "$count" "$saved"
}

while IFS='|' read -r name url color icon || [[ -n "${name:-}" ]]; do
    name="$(trim "${name:-}")"
    url="$(trim "${url:-}")"

    [[ -n "$name" && "${name:0:1}" != "#" && -n "$url" ]] || continue

    fetch_site "$name" "$url"
done < "$CONF"

printf '\nFinished. Icons are in: %s\n' "$FETCHED"
