#!/bin/bash
# Schaltet den qtile-Mode an/aus (siehe ws-switch.sh).
# qtile-Mode AN  -> Workspace-Wechsel holt den Workspace auf den Haupt-Monitor (Mitte).
# qtile-Mode AUS -> normales Hyprland-Verhalten (Workspace bleibt auf seinem Monitor).

mode_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-qtile-mode"

if [ -f "$mode_file" ]; then
  rm -f "$mode_file"
  notify-send -t 2500 "Hyprland" "qtile-Mode: AUS (normal)"
else
  touch "$mode_file"
  notify-send -t 2500 "Hyprland" "qtile-Mode: AN — Workspaces → Mitte"
fi
