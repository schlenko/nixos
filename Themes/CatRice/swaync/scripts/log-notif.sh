#!/usr/bin/env bash
# runs on every incoming notification (swaync passes SWAYNC_* env vars)
f="${XDG_RUNTIME_DIR:-/tmp}/last-notification"
printf '%s\n%s\n' "$SWAYNC_SUMMARY" "$SWAYNC_BODY" > "$f"
printf '[%s] %s: %s | %s\n' "$(date '+%F %T')" "$SWAYNC_APP_NAME" "$SWAYNC_SUMMARY" "$SWAYNC_BODY" \
  >> "$HOME/.local/share/notification-log.txt"