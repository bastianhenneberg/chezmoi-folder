#!/usr/bin/env bash
# Installiert einen pacman-Hook, der den hyprwhspr Idle-Reinit-OOM-Patch (free-before-realloc)
# nach JEDEM hyprwhspr Install/Upgrade AUTOMATISCH neu anwendet.
#
# Warum: /usr/lib/hyprwhspr/lib/src/whisper_manager.py gehoert root und wird bei jedem
#   hyprwhspr-Update ueberschrieben -> der Patch geht verloren -> der OOM-Bug kehrt zurueck
#   ("[ERROR] faster-whisper reinitialization failed: CUDA out of memory" +
#    "[WARN] No transcription generated"; Mikro zeigt Ausschlag, aber kein Text).
#   Der bestehende run_after_patch-hyprwhspr-oom-fix.sh greift NUR bei 'chezmoi apply' und
#   verliert daher das Rennen gegen zwischenzeitliche yay/pacman-Updates. Ein pacman-Hook
#   feuert dagegen bei GENAU dem Update, das die Datei ueberschreibt -> selbstheilend.
#
# Als normaler User ausfuehren (nutzt intern sudo; chezmoi apply ist interaktiv).
# Idempotent: run_onchange laeuft nur, wenn sich dieses Script aendert; die Installation
# selbst ueberschreibt Hook + Binary jedes Mal deterministisch.
set -euo pipefail

BIN=/usr/local/bin/hyprwhspr-oom-fix
HOOK=/etc/pacman.d/hooks/hyprwhspr-oom-fix.hook

# Nur NVIDIA-GPUs sind betroffen (faster-whisper/CUDA). Ohne nvidia-smi: nichts tun.
if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "[hyprwhspr-hook] Keine NVIDIA-GPU - Hook nicht noetig. Uebersprungen."
    exit 0
fi

echo "[hyprwhspr-hook] Installiere Standalone-Patcher -> $BIN"
sudo tee "$BIN" >/dev/null <<'PYEOF'
#!/usr/bin/env python3
# hyprwhspr-oom-fix: idempotenter free-before-realloc Patch fuer whisper_manager.py.
# Laeuft als root aus einem pacman-Hook (PostTransaction) nach jedem hyprwhspr-Update
# und setzt den Patch neu, den das Update ueberschrieben hat. Kein sudo/kein --user hier.
import os, re, sys

TARGET = "/usr/lib/hyprwhspr/lib/src/whisper_manager.py"
MARKER = "hyprwhspr-oom-fix"

if not os.path.isfile(TARGET):
    print("[hyprwhspr-oom-fix] Ziel nicht gefunden - hyprwhspr entfernt? Ueberspringe.")
    sys.exit(0)

with open(TARGET, encoding="utf-8") as f:
    src = f.read()

if MARKER in src:
    print("[hyprwhspr-oom-fix] Patch bereits aktiv.")
    sys.exit(0)

# Trifft BEIDE Allokations-Stellen (Erst-Load + Idle-Reinit) - beide identische Zeile.
pat = re.compile(
    r'^([ \t]*)self\._faster_whisper_model = '
    r'WhisperModel\(model_name, device=device, compute_type=compute_type\)$',
    re.M,
)

def repl(m):
    ind = m.group(1)
    return (f'{ind}# {MARKER}: alte GPU-Belegung vor Reinit freigeben (sonst OOM auf 8-GB-Karte)\n'
            f'{ind}self._faster_whisper_model = None\n'
            f'{ind}import gc as _gc; _gc.collect()\n'
            f'{ind}self._faster_whisper_model = WhisperModel(model_name, device=device, compute_type=compute_type)')

new, n = pat.subn(repl, src)
if n == 0:
    sys.stderr.write("[hyprwhspr-oom-fix] WARN: Ziel-Zeile nicht gefunden - "
                     "hyprwhspr-Quellcode hat sich geaendert. NICHT gepatcht, bitte pruefen.\n")
    sys.exit(0)  # nicht hart failen: Dienst laeuft (nur ohne Fix) weiter

with open(TARGET, "w", encoding="utf-8") as f:
    f.write(new)
print(f"[hyprwhspr-oom-fix] {n} Stelle(n) gepatcht.")
PYEOF
sudo chmod 755 "$BIN"

echo "[hyprwhspr-hook] Installiere pacman-Hook -> $HOOK"
sudo mkdir -p /etc/pacman.d/hooks
sudo tee "$HOOK" >/dev/null <<'HOOKEOF'
# Wendet den hyprwhspr free-before-realloc OOM-Patch nach jedem hyprwhspr-Update neu an.
# Verwaltet via chezmoi (run_onchange_install-hyprwhspr-oom-hook.sh). Nicht von Hand editieren.
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = hyprwhspr

[Action]
Description = hyprwhspr OOM-Patch (free-before-realloc) neu anwenden...
When = PostTransaction
Exec = /usr/local/bin/hyprwhspr-oom-fix
HOOKEOF

echo "[hyprwhspr-hook] Wende Patch jetzt einmal an ..."
sudo "$BIN"

echo "[hyprwhspr-hook] Starte hyprwhspr neu (falls User-Session vorhanden) ..."
systemctl --user restart hyprwhspr.service 2>/dev/null \
    || echo "[hyprwhspr-hook] --user Neustart uebersprungen (kein User-Bus)."

echo "[hyprwhspr-hook] Fertig. Kuenftige hyprwhspr-Updates patchen sich selbst."
