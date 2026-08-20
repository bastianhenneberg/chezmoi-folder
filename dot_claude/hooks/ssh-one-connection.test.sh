#!/usr/bin/env bash
# Regressionstest fuer ssh-one-connection.sh.
#
# Als Datei, nicht als Bash-Einzeiler: die Testfaelle enthalten die verbotenen
# Muster im Klartext und wuerden den Riegel sonst selbst ausloesen.
#
# Der Hook beendet sich IMMER mit 0 und entscheidet ueber stdout (JSON mit
# permissionDecision: deny). Geprueft wird deshalb die Ausgabe, nicht der
# Exit-Code — ein Test auf den Exit-Code waere immer gruen und damit wertlos.

HOOK="$(dirname "$0")/ssh-one-connection.sh"
fehler=0

# Zusammengesetzt, damit diese Datei nicht selbst als Verstoss gilt.
CTL="-o Control"

pruefe() {
	local erwartet="$1" name="$2" cmd="$3"
	local json ausgabe ist
	json=$(printf '%s' "$cmd" | python3 -c 'import json,sys; print(json.dumps({"tool_input":{"command": sys.stdin.read()}}))')
	ausgabe=$(printf '%s' "$json" | bash "$HOOK" 2>/dev/null)

	if printf '%s' "$ausgabe" | grep -q '"permissionDecision": *"deny"'; then
		ist="deny"
	elif [ -z "$ausgabe" ]; then
		ist="erlaubt"
	else
		ist="UNERWARTETE-AUSGABE"
	fi

	if [ "$ist" = "$erwartet" ]; then
		printf 'ok    (%-7s) %s\n' "$ist" "$name"
	else
		printf 'FEHLT erwartet=%s ist=%s  %s\n' "$erwartet" "$ist" "$name"
		fehler=1
	fi
}

# --- muessen blockiert werden ---
pruefe deny "ssh mit eigenem ControlPath" "ssh ${CTL}Path=/tmp/x host uptime"
pruefe deny "ssh mit eigenem ControlMaster" "ssh ${CTL}Master=auto host uptime"
pruefe deny "ssh mit eigenem ControlPersist" "ssh ${CTL}Persist=120 host uptime"
pruefe deny "eigener Master per -M -S" "ssh -M -S ~/.ssh/x.sock -N -f host"
pruefe deny "hinter && versteckt" "cd /tmp && ssh ${CTL}Path=/tmp/x host uptime"
pruefe deny "mit ENV-Praefix" "FOO=bar ssh ${CTL}Path=/tmp/x host uptime"

# --- muessen durchgehen ---
pruefe erlaubt "sauberer Aufruf ueber Alias" "ssh moonlit-winds 'uptime; df -h'"
pruefe erlaubt "gar kein ssh im Befehl" "grep -S foo bar"
pruefe erlaubt "sauberer Heredoc-Aufruf" "ssh host 'bash -s' <<EOF
echo hallo
EOF"
pruefe erlaubt "Doku ueber den Fehler im Heredoc" "cat > doku.md <<EOF
Niemals ssh ${CTL}Path=... benutzen!
EOF"
pruefe erlaubt "scp sauber" "scp datei.txt moonlit-winds:/tmp/"
pruefe erlaubt "grep NACH dem Muster in der Config" "grep -i ${CTL}Path ~/.ssh/config"
pruefe erlaubt "sort -M in einer Kette mit ssh" "ssh moonlit-winds 'ls' | sort -M -"

if [ "$fehler" = 0 ]; then
	echo "--- alle Faelle wie erwartet ---"
else
	echo "--- ABWEICHUNGEN, siehe oben ---"
fi
exit "$fehler"
