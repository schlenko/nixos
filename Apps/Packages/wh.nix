{ pkgs }:

pkgs.writeShellApplication {
name = "wh";

runtimeInputs = with pkgs; [
curl
jq
coreutils
findutils
];

text = ''
query="$*"
if [ -z "$query" ]; then
read -r -p "Wallhaven search: " query
fi
[ -n "$query" ] || exit 1

res="2560x1440"
if command -v hyprctl >/dev/null 2>&1; then
  detected=$(hyprctl monitors -j 2>/dev/null |
    jq -r '.[0] | "\(.width)x\(.height)"' || true)
  if [ -n "$detected" ] && [ "$detected" != "nullxnull" ]; then
    res="$detected"
  fi
fi

sorting="''${WH_SORT:-toplist}"
slug=$(printf '%s' "$query" | tr -cs 'A-Za-z0-9' '_')
dir="$HOME/Pictures/$slug"
mkdir -p "$dir"

echo "Searching Wallhaven for '$query' ($res)..."

curl -fsS -G "https://wallhaven.cc/api/v1/search" \
  --data-urlencode "q=$query" \
  --data-urlencode "categories=100" \
  --data-urlencode "purity=100" \
  --data-urlencode "sorting=$sorting" \
  --data-urlencode "topRange=1y" \
  --data-urlencode "atleast=$res" |
  jq -r '.data[].path' > "$dir/.urls"

if [ ! -s "$dir/.urls" ]; then
  echo "No results found."
  rm -f "$dir/.urls"
  exit 1
fi

echo "Downloading wallpapers to $dir"

(
  cd "$dir"
  xargs -a .urls -n 1 -P 6 curl -fsSO
)

rm -f "$dir/.urls"

echo "Done: $dir"

'';
}
