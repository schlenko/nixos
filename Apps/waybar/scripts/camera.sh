#!/usr/bin/env bash

DEV=/sys/bus/usb/devices/3-7/authorized
SIGNAL=9
ICON="󰄀"

enabled() { [ "$(cat "$DEV" 2>/dev/null)" = 1 ]; }

show() {
    if enabled; then
        printf '{"text":"%s on","class":"enabled","tooltip":"Camera enabled"}\n' "$ICON"
    else
        printf '{"text":"%s off","class":"disabled","tooltip":"Camera disabled"}\n' "$ICON"
    fi
}

toggle() {
    if enabled; then val=0; else val=1; fi

    pkexec sh -c "echo $val > $DEV"
    rc=$?

    # 126 = dialog dismissed, 127 = auth failed; stay quiet on cancel
    if [ $rc -ne 0 ] && [ $rc -ne 126 ]; then
        notify-send -u critical "Camera" "Toggle failed (exit $rc)"
    fi

    pkill -RTMIN+"$SIGNAL" -x waybar
}

case "${1:-show}" in
    show)   show ;;
    toggle) toggle ;;
esac