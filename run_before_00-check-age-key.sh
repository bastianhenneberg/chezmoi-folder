#!/usr/bin/env bash
# Bricht frueh und verstaendlich ab, wenn der age-Schluessel fehlt.
#
# Ohne ihn scheitert `chezmoi apply` sonst mitten im Lauf an der ersten
# verschluesselten Datei — mit einer age-Fehlermeldung, die nicht sagt, was zu tun
# ist, und einem halb ausgerollten Home.
set -euo pipefail

KEY="$HOME/.config/chezmoi/key.txt"
if [ ! -s "$KEY" ]; then
    echo "[chezmoi] age-Schluessel fehlt: $KEY" >&2
    echo "[chezmoi] Er liegt in Passbolt. Dort ablegen (chmod 600), dann erneut: chezmoi apply" >&2
    exit 1
fi
