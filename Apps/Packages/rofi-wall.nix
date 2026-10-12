{ pkgs }:

pkgs.writeShellApplication {
name = "rofi-wall";

runtimeInputs = with pkgs; [
rofi
imagemagick
awww
coreutils
findutils
];

text = ''
base="$HOME/Pictures"

dir=$(find "$base" -type d | sort | rofi -dmenu -i -p "Wallpaper folder") || exit 0
[ -n "$dir" ] || exit 0

cache="$HOME/.cache/rofi-wall"
mkdir -p "$cache"

menu() {
  find -L "$dir" -type f \( \
    -iname '*.png' -o \
    -iname '*.jpg' -o \
    -iname '*.jpeg' -o \
    -iname '*.webp' \
  \) | sort | while IFS= read -r f; do
    name="''${f#"$dir"/}"
    thumb="$cache/$(printf '%s' "$name" | sha256sum | cut -d ' ' -f 1).png"

    [ -f "$thumb" ] || magick "''${f}[0]" \
      -thumbnail 400x225^ \
      -gravity center \
      -extent 400x225 "$thumb"

    printf '%s\0icon\x1f%s\n' "$name" "$thumb"
  done
}

choice=$(menu | rofi -dmenu -i -show-icons \
  -theme "$HOME/.config/rofi/wallpaper.rasi" \
  -p "Wallpaper") || exit 0

[ -n "$choice" ] || exit 0

awww img "$dir/$choice" \
  --transition-type wipe \
  --transition-angle 135 \
  --transition-duration 0.8 \
  --transition-fps 60

'';
}
