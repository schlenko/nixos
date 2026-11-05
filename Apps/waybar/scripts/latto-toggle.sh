#!/usr/bin/env bash
# Toggle latto: start it expanded if it isn't running, otherwise kill it.

PATTERN='quickshell.*latto'

if pgrep -u "$USER" -f "$PATTERN" >/dev/null; then
  latto stop >/dev/null 2>&1
  pkill -u "$USER" -f "$PATTERN"
else
  LATTO_OPEN=1 setsid -f latto >/dev/null 2>&1
fi