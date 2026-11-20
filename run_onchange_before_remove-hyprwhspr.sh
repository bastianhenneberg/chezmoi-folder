#!/usr/bin/env bash
# Entfernt hyprwhspr restlos (20.11.2026, Freigabe Bastian: "wir nutzen nur
# voxtype"). Diktat laeuft ueber voxtype; welches Backend die Tasten bedienen,
# waehlt Omarchy selbst unter Setup > Defaults > Dictation (dort stehen auch
# Superwhisper). Unser eigenes Diktat-Menue und dictation-switch/-record gab es
# nur fuers Umschalten hyprwhspr <-> voxtype und sind mit entfernt.
#
# Raeumt auf, was die frueheren chezmoi-Skripte ausserhalb von $HOME hinterlassen
# haben (pacman-Hook + Patcher unter /usr/local/bin), das venv (~3 GB mit
# CUDA-Libs) und die User-Unit samt Drop-in. Die Dateien in ~/.config/hyprwhspr
# und ~/.local/bin nimmt .chezmoiremove mit.
#
# Idempotent: auf einem Rechner ohne hyprwhspr tut es nichts. Braucht sudo
# (fragt selbst) - also `chezmoi update` in einem Terminal ausfuehren.
set -uo pipefail

HOOK=/etc/pacman.d/hooks/hyprwhspr-oom-fix.hook
PATCHER=/usr/local/bin/hyprwhspr-oom-fix
UNIT_DIR="$HOME/.config/systemd/user"

if command -v systemctl >/dev/null 2>&1; then
    systemctl --user disable --now hyprwhspr.service >/dev/null 2>&1 || true
    systemctl --user reset-failed hyprwhspr.service >/dev/null 2>&1 || true
fi

# Eigene Unit-Kopie und Drop-in gehoeren keinem Paket.
rm -rf "$UNIT_DIR/hyprwhspr.service" "$UNIT_DIR/hyprwhspr.service.d"
command -v systemctl >/dev/null 2>&1 && systemctl --user daemon-reload >/dev/null 2>&1 || true

# Hook zuerst, sonst feuert er beim Entfernen des Pakets noch einmal.
if [ -e "$HOOK" ] || [ -e "$PATCHER" ]; then
    echo "[hyprwhspr] entferne pacman-Hook und OOM-Patcher (sudo)"
    sudo rm -f "$HOOK" "$PATCHER"
fi

if command -v pacman >/dev/null 2>&1 && pacman -Q hyprwhspr >/dev/null 2>&1; then
    echo "[hyprwhspr] deinstalliere Paket (sudo)"
    sudo pacman -Rns --noconfirm hyprwhspr || echo "[hyprwhspr] pacman -R fehlgeschlagen - bitte von Hand: sudo pacman -Rns hyprwhspr"
fi

if [ -d "$HOME/.local/share/hyprwhspr" ]; then
    echo "[hyprwhspr] entferne venv/Modelle in ~/.local/share/hyprwhspr"
    rm -rf "$HOME/.local/share/hyprwhspr"
fi

exit 0
