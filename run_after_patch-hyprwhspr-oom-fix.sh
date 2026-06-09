#!/usr/bin/env bash
# Patcht hyprwhspr gegen den Idle-Reinit-OOM-Bug (free-before-realloc).
#
# Problem: whisper_manager._reinitialize_faster_whisper() laedt nach >30 min Idle
#   ein NEUES WhisperModel, BEVOR das alte freigegeben wird -> kurzzeitig 2x large-v3
#   (~3.9 GB) auf der 8-GB-GPU -> "CUDA failed with error out of memory" -> hyprwhspr
#   liefert keine Transkription mehr ("[WARN] No transcription generated").
# Fix: altes Modell auf None setzen + gc.collect() VOR der Neu-Allokation.
#
# /usr/lib gehoert root und wird bei jedem hyprwhspr-Update ueberschrieben, daher laeuft
# dieses Script bei JEDEM 'chezmoi apply' (run_after_, kein once/onchange) und zieht den
# Patch idempotent (Marker-Guard) wieder nach. Braucht sudo (chezmoi apply ist interaktiv).
# Details: AI-Brain-Wiki "hyprwhspr: Deutsche Spracherkennung mit faster-whisper ...".
set -euo pipefail

TARGET="/usr/lib/hyprwhspr/lib/src/whisper_manager.py"
MARKER="hyprwhspr-oom-fix"

if [ ! -f "$TARGET" ]; then
    echo "[hyprwhspr-patch] $TARGET nicht gefunden - hyprwhspr installiert? Ueberspringe."
    exit 0
fi

# Nur NVIDIA-GPU betroffen (faster-whisper/CUDA). Ohne nvidia-smi nichts tun.
if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "[hyprwhspr-patch] Keine NVIDIA-GPU - Patch nicht noetig. Ueberspringe."
    exit 0
fi

# Schon gepatcht? -> nichts tun (kein Dienst-Neustart).
if sudo grep -q "$MARKER" "$TARGET"; then
    echo "[hyprwhspr-patch] Patch bereits aktiv."
    exit 0
fi

echo "[hyprwhspr-patch] Wende free-before-realloc Patch an ..."
sudo python3 - "$TARGET" "$MARKER" <<'PY'
import sys, re
path, marker = sys.argv[1], sys.argv[2]
with open(path, encoding='utf-8') as f:
    src = f.read()
if marker in src:
    sys.exit(0)
pat = re.compile(
    r'^([ \t]*)self\._faster_whisper_model = '
    r'WhisperModel\(model_name, device=device, compute_type=compute_type\)$',
    re.M,
)
def repl(m):
    ind = m.group(1)
    return (f'{ind}# {marker}: alte GPU-Belegung vor Reinit freigeben (sonst OOM auf 8-GB-Karte)\n'
            f'{ind}self._faster_whisper_model = None\n'
            f'{ind}import gc as _gc; _gc.collect()\n'
            f'{ind}self._faster_whisper_model = WhisperModel(model_name, device=device, compute_type=compute_type)')
new, n = pat.subn(repl, src)
if n == 0:
    sys.stderr.write('[hyprwhspr-patch] WARNUNG: Ziel-Zeile nicht gefunden - '
                     'hyprwhspr-Quellcode hat sich geaendert. Patch NICHT angewendet, bitte pruefen.\n')
    sys.exit(0)  # nicht hart abbrechen: Dienst laeuft (nur ohne Fix) weiter
with open(path, 'w', encoding='utf-8') as f:
    f.write(new)
print(f'[hyprwhspr-patch] {n} Stelle(n) gepatcht.')
PY

# Nur neu starten, wenn der Patch jetzt wirklich drin ist.
if sudo grep -q "$MARKER" "$TARGET"; then
    echo "[hyprwhspr-patch] Starte Dienst neu ..."
    systemctl --user restart hyprwhspr.service 2>/dev/null \
        || echo "[hyprwhspr-patch] Dienst-Neustart uebersprungen."
    echo "[hyprwhspr-patch] Fertig."
else
    echo "[hyprwhspr-patch] WARNUNG: Patch konnte nicht angewendet werden - bitte manuell pruefen."
fi
