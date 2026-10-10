{ pkgs, lib, ... }:

let
  # `msg "text"` / `msg -u critical -t "Title" "text"`
  msg = pkgs.writeShellApplication {
    name = "msg";
    runtimeInputs = [ pkgs.libnotify pkgs.wl-clipboard ];
    text = ''
      urgency=normal; title="Message"
      while getopts "u:t:" o; do
        case $o in
          u) urgency=$OPTARG ;;
          t) title=$OPTARG ;;
          *) exit 1 ;;
        esac
      done
      shift $((OPTIND-1))
      text="$*"
      {
        action=$(notify-send -w -A copy=Copy -u "$urgency" -a msg "$title" "$text" || true)
        if [ "$action" = copy ]; then
          printf '%s' "$text" | wl-copy
        fi
      } >/dev/null 2>&1 &
    '';
  };

  # `remind 10m take the pizza out`
  remind = pkgs.writeShellApplication {
    name = "remind";
    runtimeInputs = [ pkgs.systemd pkgs.libnotify ];
    text = ''
      when="$1"; shift
      systemd-run --user --on-active="$when" \
        notify-send -a remind -u critical "Reminder" "$*"
    '';
  };

  # `copy-notif` copies the most recent notification text
  copyNotif = pkgs.writeShellApplication {
    name = "copy-notif";
    runtimeInputs = [ pkgs.wl-clipboard pkgs.libnotify ];
    text = ''
      f="''${XDG_RUNTIME_DIR:-/tmp}/last-notification"
      [ -s "$f" ] && wl-copy < "$f" && notify-send -a copy "Copied" "last notification"
    '';
  };

  batteryWatch = pkgs.writeShellApplication {
    name = "battery-watch";
    runtimeInputs = [ pkgs.libnotify pkgs.coreutils ];
    text = ''
      bat=/sys/class/power_supply/BAT1
      state=/tmp/battery-watch-level
      cap=$(cat $bat/capacity)
      status=$(cat $bat/status)
      last=$(cat $state 2>/dev/null || echo none)

      if [ "$status" = "Discharging" ]; then
        if [ "$cap" -le 10 ] && [ "$last" != crit ]; then
          notify-send -u critical -a battery "Battery critical" "$cap% left"
          echo crit > $state
        elif [ "$cap" -le 20 ] && [ "$last" = none ]; then
          notify-send -u normal -a battery "Battery low" "$cap% left"
          echo low > $state
        fi
      else
        echo none > $state
      fi
    '';
  };

  wifiWatch = pkgs.writeShellApplication {
    name = "wifi-watch";
    runtimeInputs = [ pkgs.networkmanager pkgs.libnotify pkgs.gnugrep pkgs.gnused ];
    text = ''
      nmcli monitor | while read -r line; do
        case "$line" in
          *": connected to "*)
            notify-send -a wifi "WiFi" "Connected to ''${line##*connected to }" ;;
          *": disconnected"*)
            notify-send -a wifi "WiFi" "Disconnected" ;;
        esac
      done
    '';
  };

    btWatch = pkgs.writeShellApplication {
    name = "bt-watch";
    runtimeInputs = [ pkgs.bluez pkgs.libnotify pkgs.gnused pkgs.gnugrep pkgs.coreutils ];
    text = ''
      (while true; do sleep 3600; done) | bluetoothctl 2>/dev/null \
        | sed -u 's/\x1b\[[0-9;?]*[a-zA-Z]//g; s/\r//g' \
        | while read -r line; do
            if [[ "$line" =~ Device\ ([0-9A-F:]{17})\ Connected:\ (yes|no) ]]; then
              mac="''${BASH_REMATCH[1]}"; st="''${BASH_REMATCH[2]}"
              name=$(bluetoothctl info "$mac" | sed -n 's/^\s*Alias: //p')
              if [ "$st" = yes ]; then
                notify-send -a bluetooth "Bluetooth" "Connected: $name"
              else
                notify-send -a bluetooth "Bluetooth" "Disconnected: $name"
              fi
            fi
          done
    '';
  };

  mkService = desc: exe: {
    Unit = { Description = desc; After = [ "graphical-session.target" ]; PartOf = [ "graphical-session.target" ]; };
    Service = { ExecStart = lib.getExe exe; Restart = "always"; RestartSec = 3; };
    Install.WantedBy = [ "graphical-session.target" ];
  };

    notifHistory = pkgs.writeShellApplication {
    name = "notif-history";
    runtimeInputs = [ pkgs.rofi pkgs.wl-clipboard pkgs.coreutils ];
    text = ''
      log="$HOME/.local/share/notification-log.txt"
      [ -s "$log" ] || exit 0
      sel=$(tac "$log" | rofi -dmenu -i -p "Copy:" || true)
      if [ -n "$sel" ]; then
        printf '%s' "''${sel#*] }" | wl-copy
      fi
    '';
  };
in
{
  home.packages = [ msg remind copyNotif notifHistory pkgs.libnotify ];

  # config.json / style.css come from Themes/<theme>/swaync via home.nix
  services.swaync.enable = true;

  systemd.user.services.wifi-watch = mkService "WiFi notifications" wifiWatch;
  systemd.user.services.bt-watch   = mkService "Bluetooth notifications" btWatch;

  systemd.user.services.battery-watch = {
    Unit.Description = "Battery check";
    Service = { Type = "oneshot"; ExecStart = lib.getExe batteryWatch; };
  };
  systemd.user.timers.battery-watch = {
    Unit.Description = "Battery check timer";
    Timer = { OnBootSec = "1min"; OnUnitActiveSec = "1min"; };
    Install.WantedBy = [ "timers.target" ];
  };
}