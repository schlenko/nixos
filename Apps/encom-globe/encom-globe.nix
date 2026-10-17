{ pkgs, ... }:

let
  globeFiles = pkgs.stdenvNoCC.mkDerivation {
    pname = "encom-globe-files";
    version = "1.0";

    src = ./.;

    installPhase = ''
      mkdir -p "$out/share/encom-globe"

      cp -r \
        index.html \
        build \
        include \
        resources \
        data.js \
        grid.js \
        styles.css \
        "$out/share/encom-globe/"
    '';
  };

in
pkgs.writeShellApplication {
  name = "encom-globe";

  runtimeInputs = [
    pkgs.python3
    pkgs.chromium
    pkgs.coreutils
  ];

  text = ''
    set -euo pipefail

    port=18765
    root="${globeFiles}/share/encom-globe"
    url="http://127.0.0.1:$port/"

    # Create an isolated Chromium profile for this app.
    profile="$(mktemp -d)"

    # Start the local web server.
    python3 -m http.server "$port" \
      --bind 127.0.0.1 \
      --directory "$root" &
    server_pid=$!

    cleanup() {
      kill "$server_pid" 2>/dev/null || true
      wait "$server_pid" 2>/dev/null || true
      rm -rf "$profile"
    }

    trap cleanup EXIT
    trap 'exit 0' INT TERM

    # Wait for the server to become available.
    ready=0

    for _ in {1..50}; do
      if ! kill -0 "$server_pid" 2>/dev/null; then
        echo "ENCOM Globe server failed to start." >&2
        exit 1
      fi

      if python3 -c \
        "import urllib.request; urllib.request.urlopen('$url', timeout=1)" \
        >/dev/null 2>&1; then
        ready=1
        break
      fi

      sleep 0.1
    done

    if [ "$ready" -ne 1 ]; then
      echo "ENCOM Globe server did not become ready." >&2
      exit 1
    fi

    # Open ENCOM Globe in its own Chromium app window.
    chromium \
      --user-data-dir="$profile" \
      --no-first-run \
      --no-default-browser-check \
      --app="$url"
  '';
}