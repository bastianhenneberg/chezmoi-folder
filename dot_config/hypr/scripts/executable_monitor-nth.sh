#!/bin/bash
# Den N-ten Monitor VON LINKS fokussieren.
#
# Warum ein Skript und kein Lua: die Monitor-Tabelle aus hl.get_monitors() traegt
# keine Position (Omarchys eigener Code nutzt dort nur name/id/is_mirror), und zum
# Konfigurationszeitpunkt liefert sie ohnehin noch nichts. `hyprctl monitors -j`
# hat x/y.
#
# Warum Position und NICHT Hyprlands id: die id vergibt Hyprland in der Reihenfolge,
# in der Monitore auftauchen. Auf desktop ergab das 1=DP-1 (rechts), 3=DP-3 (links) -
# raeumlich verkehrt herum. Die Blocknummer aus monitor-workspaces.lua taugt auch
# nicht als Ordnung: die Leiste zeigt sie gar nicht an, sie beschriftet pro Monitor
# die Plaetze 1-10 (shell/plugins/bar/widgets/Workspaces.qml, slotOf()).
#
# Aufruf: monitor-nth.sh <N>
set -uo pipefail

n="${1:?Nummer fehlt}"
name=$(hyprctl monitors -j | jq -r --argjson n "$n" 'sort_by(.x) | .[$n-1].name // empty')

# Weniger Monitore als die gedrueckte Ziffer: still nichts tun.
[ -n "$name" ] || exit 0

hyprctl dispatch "hl.dsp.focus({ monitor = \"$name\" })" >/dev/null
