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

focus_ws() {
  hyprctl dispatch "hl.dsp.focus({ workspace = \"$1\" })"
}

if [ -f "$mode_file" ]; then
  # qtile-Mode: Workspace zum Zielmonitor holen, statt ihm zu folgen.
  # Erst fokussieren (damit er der aktive ist), dann herueberziehen.
  # ACHTUNG: unter Omarchy 4 noch nicht praktisch erprobt - der qtile-Mode war
  # beim Umbau aus. Falls er hakt, ist hl.dsp.workspace.move die Stelle.
  target="$MAIN_MONITOR"
  [ -z "$target" ] && target="$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')"
  focus_ws "$ws"
  [ -n "$target" ] && hyprctl dispatch "hl.dsp.workspace.move({ monitor = \"$target\" })" >/dev/null
  focus_ws "$ws"
else
  # Normal-Mode: Hyprland kennt die Heimat aus den Workspace-Rules (monitors.lua)
  # und wechselt den Monitor selbst mit. Ein zusaetzlicher monitor-Parameter
  # wuerde den Workspace-Wechsel sogar verschlucken.
  focus_ws "$ws"
fi
