#!/usr/bin/env bash
# Installiert den faster-whisper-Backend + CUDA-Libs in das hyprwhspr-venv.
# Läuft erneut, sobald sich die Paketliste unten ändert (run_onchange_ hasht den Inhalt).
# Voraussetzung: hyprwhspr (AUR) ist installiert -> venv existiert.
# Setup-Details & Stolpersteine: AI-Brain-Wiki "hyprwhspr: Deutsche Spracherkennung ...".
set -euo pipefail

VENV="$HOME/.local/share/hyprwhspr/venv"

# Paketliste (Änderung hier triggert Neu-Lauf):
#   faster-whisper==1.2.1  (--no-deps! sonst zieht es ein 2. CPU-onnxruntime neben onnxruntime-gpu -> Konflikt)
#   ctranslate2 av tokenizers           = echte Laufzeit-Deps von faster-whisper
#   nvidia-cublas-cu12 nvidia-cudnn-cu12 = CUDA-Libs; hyprwhspr lädt sie selbst per RTLD_GLOBAL aus dem venv
PKGS_FW="faster-whisper==1.2.1"
PKGS_DEPS="ctranslate2 av tokenizers nvidia-cublas-cu12 nvidia-cudnn-cu12"

if [ ! -x "$VENV/bin/python" ]; then
    echo "[hyprwhspr] venv nicht gefunden ($VENV)."
    echo "[hyprwhspr] Bitte zuerst hyprwhspr installieren (z.B. 'yay -S hyprwhspr'), dann 'chezmoi apply' erneut."
    exit 0
fi

if ! command -v nvidia-smi >/dev/null 2>&1; then
    echo "[hyprwhspr] Keine NVIDIA-GPU erkannt (nvidia-smi fehlt) - überspringe faster-whisper/CUDA-Install."
    echo "[hyprwhspr] Für AMD/Intel besser onnx-asr (parakeet-v3) in der config.json verwenden."
    exit 0
fi

echo "[hyprwhspr] Installiere faster-whisper-Backend ins venv ..."
"$VENV/bin/python" -m pip install --no-input $PKGS_FW --no-deps
"$VENV/bin/python" -m pip install --no-input $PKGS_DEPS

echo "[hyprwhspr] Prüfe CUDA-Verfügbarkeit ..."
"$VENV/bin/python" - <<'PY'
import os, glob, site, ctypes
for sd in site.getsitepackages():
    for pkg, so in [('cublas', 'libcublas.so.12'), ('cudnn', 'libcudnn.so.9')]:
        for f in glob.glob(os.path.join(sd, 'nvidia', pkg, 'lib', so + '*')):
            try: ctypes.CDLL(f, mode=ctypes.RTLD_GLOBAL)
            except OSError: pass
import ctranslate2
n = ctranslate2.get_cuda_device_count()
print(f"[hyprwhspr] CUDA-Geräte sichtbar: {n}")
raise SystemExit(0 if n > 0 else 1)
PY

echo "[hyprwhspr] Starte Dienst neu ..."
systemctl --user restart hyprwhspr.service 2>/dev/null || echo "[hyprwhspr] Dienst-Neustart übersprungen (läuft evtl. nicht als user-service)."
echo "[hyprwhspr] Fertig. Bei VRAM-Knappheit in config.json faster_whisper_model auf 'large-v3-turbo' setzen."
