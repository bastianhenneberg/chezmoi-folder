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
#
# HYPRLAND 0.56 / OMARCHY 4: `hyprctl dispatch <name> <arg>` gibt es nicht mehr.
# hyprctl baut aus dem Rest der Zeile Lua (`return hl.dispatch(<rest>)`), an dem
# die alte Syntax mit ")' expected near ..." zerbricht. Statt focusmonitor +
# focusworkspaceoncurrentmonitor nacheinander gibt es jetzt einen Aufruf:
#   hl.dsp.focus({ workspace = "N", monitor = "NAME" })
# Ein Aequivalent zu focusworkspaceoncurrentmonitor gibt es nicht mehr, deshalb
# wird der Zielmonitor immer explizit benannt - im qtile-Mode ohne MAIN_MONITOR
# ist das der gerade fokussierte.

ws="$1"
mode_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-qtile-mode"
conf="$HOME/.config/hypr/scripts/qtile-mode.conf"

MAIN_MONITOR=""
[ -f "$conf" ] && . "$conf"

# Workspace auf einem bestimmten Monitor fokussieren. Ohne Monitor bleibt es bei
# Hyprlands Standardverhalten (Workspace auf seinem Heimat-Monitor).
focus_ws() {
  local target_ws="$1" target_mon="$2"
  if [ -n "$target_mon" ]; then
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$target_ws\", monitor = \"$target_mon\" })"
  else
    hyprctl dispatch "hl.dsp.focus({ workspace = \"$target_ws\" })"
  fi
}

if [ -f "$mode_file" ]; then
  # qtile-Mode: auf den Haupt-Monitor (oder, falls leer, den fokussierten) holen
  target="$MAIN_MONITOR"
  [ -z "$target" ] && target="$(hyprctl activeworkspace -j | jq -r '.monitor // empty')"
  focus_ws "$ws" "$target"
else
  # Normal-Mode: Heimat-Monitor dynamisch aus den Workspace-Rules ermitteln
  home="$(hyprctl workspacerules -j | jq -r --arg w "$ws" '.[] | select(.workspaceString==$w) | .monitor // empty' | head -1)"
  focus_ws "$ws" "$home"
fi
