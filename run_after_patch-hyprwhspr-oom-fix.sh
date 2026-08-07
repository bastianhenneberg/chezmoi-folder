#!/usr/bin/env bash
# Zieht den hyprwhspr-OOM-Patch (free-before-realloc) bei jedem 'chezmoi apply' nach.
#
# Problem: Der faster-whisper-Backend laedt nach laengerem Idle ein NEUES WhisperModel,
#   BEVOR das alte freigegeben wird -> kurzzeitig zwei Modelle auf der GPU -> "CUDA failed
#   with error out of memory", und hyprwhspr liefert keine Transkription mehr
#   ("[WARN] No transcription generated"). Fix: altes Modell auf None + gc.collect() VOR
#   der Neu-Allokation.
#
# /usr/lib gehoert root und wird bei jedem hyprwhspr-Update ueberschrieben, der Patch geht
# also regelmaessig verloren. Dagegen gibt es zwei Netze:
#
#   1. Ein pacman-Hook (run_onchange_install-hyprwhspr-oom-hook.sh) — feuert bei genau dem
#      Update, das die Datei ueberschreibt. Das ist das wirksame Netz.
#   2. Dieses Script — greift zusaetzlich bei jedem 'chezmoi apply', etwa auf einem
#      Rechner, auf dem der Hook noch nicht installiert ist.
#
# Die Patch-Logik selbst steht NICHT mehr hier: Sie lag frueher in beiden Dateien doppelt,
# beide mit dem Pfad fest verdrahtet — und als hyprwhspr die Allokation mit 1.38 in
# backends/faster_whisper_backend.py verschob, liefen beide still ins Leere. Eine Logik,
# zwei Aufrufer.
set -euo pipefail

PATCHER=/usr/local/bin/hyprwhspr-oom-fix

if [ ! -x "$PATCHER" ]; then
    echo "[hyprwhspr-patch] $PATCHER fehlt - wird von run_onchange_install-hyprwhspr-oom-hook.sh angelegt."
    echo "[hyprwhspr-patch] Uebersprungen."
    exit 0
fi

sudo "$PATCHER"

# Nur neu starten, wenn wirklich etwas gepatcht wurde — ein Neustart ohne Anlass kostet
# eine Modell-Ladezeit und bringt nichts.
if sudo grep -rqs "hyprwhspr-oom-fix" /usr/lib/hyprwhspr/lib/src/; then
    echo "[hyprwhspr-patch] Starte Dienst neu ..."
    if systemctl --user is-active --quiet hyprwhspr.service 2>/dev/null; then
        systemctl --user restart hyprwhspr.service 2>/dev/null \
            || echo "[hyprwhspr-patch] Dienst-Neustart uebersprungen (kein User-Bus)."
    else
        echo "[hyprwhspr-patch] Dienst laeuft hier nicht - kein Neustart."
    fi
    echo "[hyprwhspr-patch] Fertig."
else
    echo "[hyprwhspr-patch] WARNUNG: Patch nicht aktiv - hyprwhspr-Quellcode pruefen."
fi
