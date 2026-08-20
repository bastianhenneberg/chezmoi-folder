#!/usr/bin/env bash
# Regressionstest fuer ssh-one-connection.sh.
# Als Datei, nicht als Bash-Einzeiler: die Testfaelle enthalten die verbotenen
# Muster im Klartext und wuerden den Riegel sonst selbst ausloesen.

HOOK="$(dirname "$0")/ssh-one-connection.sh"
fehler=0

# Bausteine zusammensetzen, damit die Datei nicht selbst als Verstoss gilt,
# falls sie je durch eine Pruefung laeuft.
CTL="-o Control"
pruefe() {
    local erwartet="$1" name="$2" cmd="$3"
    local json ist
    json=$(printf '%s' "$cmd" | python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command": sys.stdin.read()}}))')
    printf '%s' "$json" | bash "$HOOK" >/dev/null 2>&1
    ist=$?
    if [ "$ist" = "$erwartet" ]; then
        printf 'ok    (%s) %s\n' "$ist" "$name"
    else
        printf 'FEHLT erwartet=%s ist=%s  %s\n' "$erwartet" "$ist" "$name"
        fehler=1
    fi
}

pruefe 2 "ssh mit eigenem ControlPath"        "ssh ${CTL}Path=/tmp/x host uptime"
pruefe 2 "ssh mit eigenem ControlMaster"      "ssh ${CTL}Master=auto host uptime"
pruefe 2 "eigener Master per -M -S"           "ssh -M -S ~/.ssh/x.sock -N -f host"
pruefe 0 "sauberer Aufruf ueber Alias"        "ssh moonlit-winds 'uptime; df -h'"
pruefe 0 "gar kein ssh im Befehl"             "grep -S foo bar"
pruefe 0 "sauberer Heredoc-Aufruf"            "ssh host 'bash -s' <<EOF
echo hallo
EOF"
pruefe 0 "Doku ueber den Fehler im Heredoc"   "cat > doku.md <<EOF
Niemals ssh ${CTL}Path=... benutzen!
EOF"
pruefe 0 "scp sauber"                         "scp datei.txt moonlit-winds:/tmp/"

if [ "$fehler" = 0 ]; then
    echo "--- alle Faelle wie erwartet ---"
else
    echo "--- ABWEICHUNGEN, siehe oben ---"
fi
exit "$fehler"
