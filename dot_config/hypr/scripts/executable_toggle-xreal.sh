#!/usr/bin/env bash
# Desktop: switches the XREAL glasses on HDMI-A-1 off and on again. monitors.lua
# reads the marker on every reload, so the choice holds until the next login.
marker="${XDG_RUNTIME_DIR:-/tmp}/xreal-off"
if [ -e "$marker" ]; then
    rm -f "$marker"
    state="on"
else
    touch "$marker"
    state="off"
fi
hyprctl reload >/dev/null
notify-send -t 2000 "XREAL" "Glasses $state"
