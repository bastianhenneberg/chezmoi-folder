#!/usr/bin/env bash
#
# SSH-Guardrail: verhindert, dass ein Aufruf das global konfigurierte
# Multiplexing aushebelt.
#
# Hintergrund: ~/.ssh/config setzt in der `Host *`-Sektion ControlMaster auto,
# ControlPersist 10m und ControlPath ~/.ssh/cm/%r@%h:%p. Damit laufen alle
# Befehle an denselben Host durch EINE Verbindung — ohne dass irgendetwas
# mitgegeben werden muesste.
#
# Wer eigene -o ControlPath/-o ControlMaster/-S/-M mitgibt, zeigt auf einen
# ANDEREN Socket als den konfigurierten. SSH findet dort keinen Master und baut
# neu auf. Der Aufruf sieht nach Wiederverwendung aus und ist das Gegenteil.
#
# Auf den infra-monitor-Hosts laeuft ein fail2ban-Jail: nach wenigen frischen
# Verbindungen kommt "Connection timed out", waehrend die Webseiten weiter mit
# 200 antworten — sieht nach Serverausfall aus, ist selbstverschuldet.
#
# Siehe Memory learning_ssh_one_connection_not_many.

set -uo pipefail

cmd=$(jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

# Heredoc-Inhalte abschneiden: was dort steht, ist Nutzlast (Dokumentation,
# Python-Skripte, Commit-Nachrichten) und wird von dieser Shell nicht als ssh
# ausgefuehrt. Ohne diesen Schnitt blockiert der Riegel das Schreiben ueber
# sich selbst — am 20.08.2026 prompt passiert. Ein echter ssh-Aufruf steht
# immer VOR dem `<<` (auch bei `ssh host 'bash -s' <<EOF`).
pruef=${cmd%%<<*}

# Nur eingreifen, wenn ueberhaupt ssh/scp/sftp im Spiel ist.
printf '%s' "$pruef" | grep -qE '(^|[;&|(`[:space:]])(ssh|scp|sftp)([[:space:]]|$)' || exit 0

msg=""
if printf '%s' "$pruef" | grep -qiE '\-o[[:space:]]*"?'\''?Control(Path|Master|Persist)'; then
    msg="eigene -o Control*-Flags ueberschreiben ~/.ssh/config und erzwingen eine NEUE Verbindung"
elif printf '%s' "$pruef" | grep -qE '(ssh|scp|sftp)[^;|&]*[[:space:]]-[MS][[:space:]]'; then
    msg="-M/-S bauen einen eigenen Master neben dem bereits konfigurierten"
fi

if [ -n "$msg" ]; then
    {
        echo "SSH-GUARDRAIL blockiert: $msg."
        echo
        echo "Dieser Rechner multiplext BEREITS global:"
        echo "  ControlMaster auto | ControlPersist 10m | ControlPath ~/.ssh/cm/%r@%h:%p"
        echo "Es ist nichts einzurichten — nur nichts kaputtzumachen."
        echo
        echo "Richtig:"
        echo "  ssh <alias> 'befehl1; befehl2; befehl3'      # mehrere Befehle in EINEN Aufruf"
        echo "  ssh <alias> 'bash -s' <<'EOF' ... EOF        # fuer laengere Skripte"
        echo
        echo "Warten/Pollen gehoert AUF den Server (Schleife innerhalb des einen Aufrufs),"
        echo "nicht in eine lokale Schleife, die im Takt neu anklopft."
        echo
        echo "Fehlt ein Host-Alias? In ~/.ssh/config eintragen (Host/HostName/User/"
        echo "IdentityFile/IdentitiesOnly) — die Control-Einstellungen erbt er automatisch."
        echo "Pruefen mit: ssh -G <alias> | grep -i control"
    } >&2
    exit 2
fi

exit 0
