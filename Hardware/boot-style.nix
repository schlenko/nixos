{ config, lib, pkgs, ... }:

let
    summary = pkgs.writeShellScript "boot-summary" ''
    export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.gawk ]}:$PATH
    ctl=${config.systemd.package}/bin/systemctl

    ok=$($ctl list-units --type=service --state=active --no-legend | wc -l)
    bad=$($ctl list-units --state=failed --no-legend | wc -l)
    secs=$(awk '{printf "%.1f", $1}' /proc/uptime)

    # palette slots (bright variants, see console.colors)
    B=$'\033[95m'      # border: purple
    G=$'\033[96m'      # success: bright cyan/mint
    R=$'\033[91m'      # failure: bright red
    Y=$'\033[93m'      # timer: yellow
    W=$'\033[97;1m'    # labels: bold white
    X=$'\033[0m'

    if [ "$bad" -eq 0 ]; then
      rc=$G; result="SUCCESS"; fc=$G
    else
      rc=$R; result="DEGRADED"; fc=$R
    fi

    row() { printf '%s║%s  %-20s%s%14s%s  %s║%s\n' "$B" "$W" "$1" "$2" "$3" "$X" "$B" "$X"; }

    printf '\n%s╔══════════════════════════════════════╗%s\n' "$B" "$X"
    printf '%s║%s%14s%sDO WHATEVER YOU WANT%s%14s%s║%s\n' "$B" "$X" "" "$W" "$X" "" "$B" "$X"
    printf '%s╠══════════════════════════════════════╣%s\n' "$B" "$X"
    row "Services loaded:" "$G" "$ok"
    row "Services failed:" "$fc" "$bad"
    row "Boot time:"       "$Y" "''${secs}s"
    row "Boot result:"     "$rc" "$result"
    printf '%s╚══════════════════════════════════════╝%s\n' "$B" "$X"
  '';
in
{
  # console colors + font (from Option A)
  console = {
    earlySetup = true;
    font = "ter-v12n";
    packages = [ pkgs.terminus_font ];
    keyMap = "de";
    colors = [
        "000000" # 0  background
        "ff5c8a" # 1  red
        "78c8ff" # 2  green slot, remapped to light blue
        "ffd166" # 3  yellow
        "6ea8fe" # 4  blue
        "bd93f9" # 5  purple
        "5de4c7" # 6  cyan
        "d8dee9" # 7  white

        "454052" # 8  bright black
        "ff7597" # 9  bright red
        "9bdcff" # 10 bright green slot, remapped to light blue
        "ffe08a" # 11 bright yellow
        "8bb8ff" # 12 bright blue
        "d6b3ff" # 13 bright purple
        "7af0d5" # 14 bright cyan
        "ffffff" # 15 bright white
    ];
  };

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;

    systemd.services.boot-summary = {
    wantedBy = [ "graphical.target" ];    
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      StandardOutput = "tty";
      TTYPath = "/dev/console";
      ExecStart = summary;
    };
  };
}