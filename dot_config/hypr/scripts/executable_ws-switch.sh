#!/bin/bash
# Workspace-Switch mit optionalem qtile-Mode. Maschinen-unabhaengig.
#
# Normal-Mode (Hyprland default): Workspace auf seinen Heimat-Monitor holen.
#   Die Heimat wird dynamisch aus 'hyprctl workspacerules' gelesen
#   (kommt aus monitors.conf -> je Rechner automatisch korrekt).
# qtile-Mode: Workspace auf den Haupt-Monitor holen. Der steht in
#   qtile-mode.conf (MAIN_MONITOR, je Rechner getemplatet). Ist er leer,
#   kommt der Workspace auf den aktuell fokussierten Monitor (klassisches qtile).
#
# Umschaltbar via toggle-qtile-mode.sh.

ws="$1"
mode_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-qtile-mode"
conf="$HOME/.config/hypr/scripts/qtile-mode.conf"

MAIN_MONITOR=""
[ -f "$conf" ] && . "$conf"

if [ -f "$mode_file" ]; then
  # qtile-Mode: auf den Haupt-Monitor (oder, falls leer, den fokussierten) holen
  [ -n "$MAIN_MONITOR" ] && hyprctl dispatch focusmonitor "$MAIN_MONITOR" >/dev/null
  hyprctl dispatch focusworkspaceoncurrentmonitor "$ws"
else
  # Normal-Mode: Heimat-Monitor dynamisch aus den Workspace-Rules ermitteln
  home="$(hyprctl workspacerules -j | jq -r --arg w "$ws" '.[] | select(.workspaceString==$w) | .monitor // empty' | head -1)"
  if [ -n "$home" ]; then
    hyprctl dispatch focusmonitor "$home" >/dev/null
    hyprctl dispatch focusworkspaceoncurrentmonitor "$ws"
  else
    hyprctl dispatch workspace "$ws"
  fi
fi
