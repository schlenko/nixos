#!/usr/bin/env bash

DEV=/sys/bus/usb/devices/3-7/authorized
ICON="󰄀"

enabled() { [ "$(cat "$DEV" 2>/dev/null)" = 1 ]; }

show() {
    if enabled; then
        printf '{"text":"%s on","class":"enabled","tooltip":"Camera enabled"}\n' "$ICON"
    else
        printf '{"text":"%s off","class":"disabled","tooltip":"Camera disabled"}\n' "$ICON"
    fi
}

# long-running: one instance per bar, redraws only when it gets USR1
watch() {
    trap show USR1
    show
    sleep infinity &
    sp=$!
    trap 'kill $sp 2>/dev/null' EXIT
    while true; do wait "$sp"; done
}

toggle() {
    if enabled; then val=0; else val=1; fi

    pkexec sh -c "echo $val > $DEV"
    rc=$?

    # 126 = dialog dismissed, 127 = auth failed; stay quiet on cancel
    if [ $rc -ne 0 ] && [ $rc -ne 126 ]; then
        notify-send -u critical "Camera" "Toggle failed (exit $rc)"
    fi

    # wake every running watcher (one per bar)
    pkill -USR1 -f "camera.sh watch"
}

case "${1:-show}" in
    show)   show ;;
    watch)  watch ;;
    toggle) toggle ;;
esac