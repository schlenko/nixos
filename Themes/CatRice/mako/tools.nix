{ pkgs }:

rec {
  notify-sound = pkgs.writeShellScriptBin "notify-sound" ''
    exec ${pkgs.pipewire}/bin/pw-play \
      "${pkgs.kdePackages.ocean-sound-theme}/share/sounds/ocean/stereo/$1.oga"
  '';

  battery-notify = pkgs.writeShellScriptBin "battery-notify" ''
    export PATH=${pkgs.lib.makeBinPath [ pkgs.libnotify pkgs.systemd pkgs.upower pkgs.coreutils notify-sound ]}:$PATH
    ${builtins.readFile ./scripts/battery.sh}
  '';

    nixos-rebuild-notify = pkgs.writeShellScriptBin "nixos-rebuild-notify" ''
    set -o pipefail
    export PATH=${pkgs.lib.makeBinPath [ pkgs.libnotify pkgs.git pkgs.gnused pkgs.gnugrep pkgs.coreutils ]}:$PATH

    # flakes ignore untracked files
    git -C /etc/nixos add -A 2>/dev/null

    log=$(mktemp)
    if sudo nixos-rebuild "$@" 2>&1 | tee "$log"; then
      gen=$(readlink /nix/var/nix/profiles/system | grep -o '[0-9]\+')
      ${notify-sound}/bin/notify-sound completion-success
      notify-send -a rebuild "󰄬 Rebuild successful" "Now on generation $gen"
    else
      err=$(sed 's/\x1b\[[0-9;]*m//g' "$log" | grep -i 'error' | tail -n 3 \
            | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' | cut -c1-120)
      [ -z "$err" ] && err="See the terminal for details"
      ${notify-sound}/bin/notify-sound dialog-error
      notify-send -a rebuild -u critical "󰅚 Rebuild failed" "$err"
    fi
    rm -f "$log"
  '';
}