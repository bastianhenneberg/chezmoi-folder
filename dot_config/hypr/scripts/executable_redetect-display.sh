#!/usr/bin/env bash
# After the XREAL switches between 16:9 and 32:9: make the kernel re-read the
# HDMI port (the adapter does not report the change), then reload Hyprland so
# bastian.lua picks mode and scale for what the glasses offer now.
# Needs /etc/sudoers.d/91-display-detect, which allows exactly this tee.

for status in /sys/class/drm/card*-HDMI-A-1/status; do
    echo detect | sudo -n /usr/bin/tee "$status" >/dev/null
done
sleep 2
hyprctl reload >/dev/null
