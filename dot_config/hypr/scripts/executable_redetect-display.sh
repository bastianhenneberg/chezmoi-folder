#!/usr/bin/env bash
# After the XREAL switches between 16:9 and 32:9: make the kernel re-read the
# HDMI port (the adapter does not report the change), then reload Hyprland so
# bastian.lua picks mode and scale for what the glasses offer now.
# Needs /etc/sudoers.d/91-display-detect, which allows exactly this tee.

# monitor.added fires again when the reload re-adds the output: at most once
# every 10 s, so that cannot turn into a loop.
stamp="${XDG_RUNTIME_DIR:-/tmp}/redetect-display.stamp"
if [ -e "$stamp" ] && [ $(( $(date +%s) - $(stat -c %Y "$stamp") )) -lt 10 ]; then
    exit 0
fi
touch "$stamp"
sleep 1

for status in /sys/class/drm/card*-HDMI-A-1/status; do
    echo detect | sudo -n /usr/bin/tee "$status" >/dev/null
done
sleep 2
hyprctl reload >/dev/null
# Waybar keeps the bar it built for the old output size; on 32:9 it was gone.
sleep 1
systemctl --user restart waybar.service
