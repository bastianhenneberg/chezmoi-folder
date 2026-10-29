#!/bin/bash
# Omarchy-Leiste auf das eigene Audio-Panel (bastian.audio) umstellen.
# Es zeigt zusaetzlich die Ports eines Geraets (Kopfhoerer/Lautsprecher,
# Headset-/internes Mikro) - Daten aus ~/.local/bin/audio-port.
# shell.json ist pro Rechner und nicht chezmoi-verwaltet, daher nur die
# Widget-ID tauschen statt die ganze Datei zu ueberschreiben.
f="$HOME/.config/omarchy/shell.json"
[ -f "$f" ] || exit 0
grep -q '"omarchy.audio"' "$f" || exit 0
sed -i 's/"id": *"omarchy.audio"/"id": "bastian.audio"/' "$f"
echo "Omarchy-Leiste: omarchy.audio -> bastian.audio"
# Das Hot-Reload der Leiste tauscht nur die Widget-ID, laedt das Plugin aber
# nicht wirklich - erst ein Neustart der Shell zeigt das neue Panel.
command -v omarchy >/dev/null && omarchy restart shell >/dev/null 2>&1 || true
