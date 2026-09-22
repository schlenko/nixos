#!/usr/bin/env bash

if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

exec wlogout --protocol layer-shell -b 6