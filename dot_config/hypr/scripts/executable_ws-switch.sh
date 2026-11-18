#!/bin/bash
# Workspace-Switch. Maschinen-unabhaengig.
#
# NUR NOCH FUER DEN RUECKWEG: siehe ~/.config/hypr/rueckweg-globale-workspaces.lua.
# Im Normalbetrieb seit 18.11.2026 ungenutzt - die Tasten liegen auf Omarchys
# eigenen Per-Monitor-Workspaces.
#
# Workspace auf seinen Heimat-Monitor holen. Die Heimat kommt aus den
# workspace_rules, die der Rueckweg je Rechner setzt.
#
# Der frueher hier eingebaute qtile-Mode ist am 18.11.2026 entfallen: Omarchy
# bringt Scrolling-Layouts inzwischen selbst mit.
#
# HYPRLAND 0.56 / OMARCHY 4: `hyprctl dispatch <name> <arg>` gibt es nicht mehr.
# hyprctl baut aus dem Rest der Zeile Lua (`return hl.dispatch(<rest>)`), an dem
# die alte Syntax mit ")' expected near ..." zerbricht. Statt focusmonitor +
# focusworkspaceoncurrentmonitor nacheinander gibt es jetzt einen Aufruf:
#   hl.dsp.focus({ workspace = "N", monitor = "NAME" })
# Ein Aequivalent zu focusworkspaceoncurrentmonitor gibt es nicht mehr.

ws="$1"

# Hyprland kennt die Heimat aus den workspace_rules und wechselt den Monitor
# selbst mit. Ein zusaetzlicher monitor-Parameter wuerde den Workspace-Wechsel
# sogar verschlucken.
hyprctl dispatch "hl.dsp.focus({ workspace = \"$ws\" })"
