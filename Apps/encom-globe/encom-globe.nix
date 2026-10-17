
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

    profile="$(mktemp -d)"

    server_pid=""
    chromium_pid=""

    cleanup() {
      if [ -n "$chromium_pid" ]; then
        kill "$chromium_pid" 2>/dev/null || true
      fi

      if [ -n "$server_pid" ]; then
        kill "$server_pid" 2>/dev/null || true
        wait "$server_pid" 2>/dev/null || true
      fi

      rm -rf "$profile"
    }

    trap cleanup EXIT
    trap 'exit 0' INT TERM

    # Start the local ENCOM Globe server.
    python3 -m http.server "$port" \
      --bind 127.0.0.1 \
      --directory "$root" &
    server_pid=$!

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

    # Launch ENCOM Globe with a black initial background.
    chromium \
      --user-data-dir="$profile" \
      --no-first-run \
      --no-default-browser-check \
      --disable-extensions \
      --use-gl=angle \
      --use-angle=swiftshader \
      --force-dark-mode \
      --default-background-color=000000 \
      --app="$url" &
    chromium_pid=$!

    # Keep the launcher alive while the globe is running.
    wait "$chromium_pid"
  '';
}
