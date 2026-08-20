#!/usr/bin/env bash
# PreToolUse-Guard: SSH multiplext auf diesen Rechnern bereits — eigene
# Control-Flags schalten es AB.
#
# ~/.ssh/config setzt in der `Host *`-Sektion ControlMaster auto,
# ControlPersist 10m und ControlPath ~/.ssh/cm/%r@%h:%p. Der erste Aufruf baut
# die Verbindung auf, jeder weitere laeuft durch denselben Socket. Es ist also
# nichts einzurichten — nur nichts kaputtzumachen.
#
# Wer -o ControlPath / -o ControlMaster / -S / -M mitgibt, zeigt auf einen
# ANDEREN Socket, findet dort keinen Master und baut pro Befehl neu auf. Auf den
# infra-monitor-Hosts schlaegt dann fail2ban zu: "Connection timed out",
# waehrend die Webseiten desselben Servers weiter 200 liefern — sieht nach
# Serverausfall aus, ist selbstverschuldet.
#
# Bewusst durchgelassen:
#   - alles hinter dem ersten `<<` (Heredoc-Nutzlast: Dokumentation, Skripte,
#     Commit-Nachrichten). Ein echter Aufruf steht IMMER davor — auch bei
#     `ssh host 'bash -s' <<EOF`.
#   - alles, was ein Segment nicht ANFAENGT. Damit bleibt `grep -o ControlPath
#     ~/.ssh/config` erlaubt.
#
# Exit 0 + JSON auf stdout = Entscheidung. Ohne Ausgabe laeuft der Befehl normal.

set -uo pipefail

eingabe="$(cat)"
befehl="$(printf '%s' "$eingabe" | jq -r '.tool_input.command // empty' 2>/dev/null)"

[ -z "$befehl" ] && exit 0

# Heredoc-Nutzlast abschneiden — sonst blockiert der Riegel das Schreiben ueber
# sich selbst.
pruef="${befehl%%<<*}"

# Den Begruendungstext als Variable aufbauen und per --arg uebergeben, NICHT im
# jq-Programm zusammensetzen: der Text enthaelt Anfuehrungszeichen beider Sorten,
# und die beenden sonst die Bash-Zeichenkette. Genau daran ist eine fruehere
# Fassung gescheitert — jq bekam ein abgeschnittenes Programm, brach mit einem
# Syntaxfehler ab, und der Riegel liess ALLES durch, ohne dass es auffiel.
verweigern() {
	local grund="$1" text
	text=$(
		cat <<'ENDE'
Dieser Rechner multiplext BEREITS global (ControlMaster auto, ControlPersist 10m,
ControlPath ~/.ssh/cm/%r@%h:%p). Eigene Control-Flags zeigen auf einen anderen
Socket, finden dort keinen Master und erzwingen pro Befehl eine NEUE Verbindung.
Auf den infra-monitor-Hosts loest das die fail2ban-Sperre aus: "Connection timed
out", waehrend die Webseiten desselben Servers weiter 200 liefern.

Richtig:
  ssh <alias> 'befehl1; befehl2; befehl3'   # mehrere Befehle, EIN Aufruf
  ssh <alias> 'bash -s' <<'EOF' ... EOF     # fuer laengere Skripte

Warten/Pollen gehoert AUF den Server (Schleife innerhalb des einen Aufrufs),
nicht in eine lokale Schleife, die im Takt neu anklopft.

Fehlt ein Host-Alias? In ~/.ssh/config eintragen (Host/HostName/User/
IdentityFile/IdentitiesOnly) — die Control-Einstellungen erbt er automatisch.
Pruefen mit: ssh -G <alias> | grep -i control
ENDE
	)

	jq -n --arg g "$grund" --arg t "$text" \
		'{hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: ("SSH-GUARDRAIL: " + $g + ".\n\n" + $t)
      }}' || {
		# Faellt jq aus, darf der Riegel NICHT stillschweigend durchlassen.
		echo "SSH-GUARDRAIL: $grund (jq-Ausgabe fehlgeschlagen)" >&2
		exit 2
	}
	exit 0
}

# Befehlskette in Segmente zerlegen: nur was ein Segment ANFAENGT, ist ein Aufruf.
segmente="$(printf '%s' "$pruef" | sed 's/&&/\n/g; s/||/\n/g; s/;/\n/g; s/|/\n/g')"

while IFS= read -r segment; do
	segment="$(printf '%s' "$segment" | sed 's/^[[:space:]]*//')"
	# fuehrende ENV-Zuweisungen abschneiden (FOO=bar ssh ...)
	while printf '%s' "$segment" | grep -qE '^[A-Za-z_][A-Za-z0-9_]*='; do
		segment="$(printf '%s' "$segment" | sed 's/^[^[:space:]]*[[:space:]]*//')"
	done

	case "$segment" in
	ssh\ * | scp\ * | sftp\ *) ;;
	*) continue ;;
	esac

	if printf '%s' "$segment" | grep -qiE '\-o[[:space:]]*"?'\''?Control(Path|Master|Persist)'; then
		verweigern "eigene -o Control*-Flags ueberschreiben ~/.ssh/config"
	fi

	if printf '%s' "$segment" | grep -qE '[[:space:]]-[MS][[:space:]]'; then
		verweigern "-M/-S bauen einen eigenen Master neben dem bereits konfigurierten"
	fi
done <<<"$segmente"

exit 0
