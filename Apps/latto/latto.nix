{ pkgs, src }:

let
  runtimeDeps = with pkgs; [
    quickshell
    brightnessctl
    pulseaudio        # pactl
    networkmanager    # nmcli
    curl
    libnotify
    jq
    cliphist
    wl-clipboard
    khal
    playerctl
    hyprsunset
    systemd
    coreutils
    procps
    gnugrep
    gnused
  ];
in
pkgs.writeShellScriptBin "latto" ''
  export PATH=${pkgs.lib.makeBinPath runtimeDeps}:$PATH
  exec ${src}/bin/latto "$@"
''