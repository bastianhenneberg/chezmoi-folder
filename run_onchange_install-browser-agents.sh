#!/usr/bin/env bash
# Browser-Werkzeuge für Coding-Agenten, unabhängig vom Claude-Account:
#   - agent-browser (Vercel): CLI, der Agent ruft es per Bash auf
#   - Claude in Chrome nicht mehr standardmäßig an
# Die MCP-Server (playwright, chrome-devtools, *-tunnel auf der codingmachine)
# trägt seit dem 15.10.2026 der AI-Brain-Harness ein: Repository-Typ `mcp`,
# Auswahl je Rechner, dann `ai-brain-harness sync`. Skill browser-werkzeuge.
# Idempotent; läuft erneut, sobald sich diese Datei ändert.
set -u

command -v npm >/dev/null || { echo "browser-agents: npm fehlt, übersprungen"; exit 0; }

BROWSER="$(command -v chromium || command -v google-chrome-stable || command -v google-chrome || true)"

# agent-browser (ohne root: npm-Prefix schreibgeschützt oder nicht im PATH → ~/.local)
NPM_PREFIX=()
p="$(npm config get prefix)"
[ -w "$p/lib" ] && case ":$PATH:" in *":$p/bin:"*) ;; *) false ;; esac \
  || NPM_PREFIX=(--prefix "$HOME/.local")
npm i -g "${NPM_PREFIX[@]}" --allow-scripts=agent-browser agent-browser@latest >/dev/null 2>&1 \
  && echo "browser-agents: $(agent-browser --version 2>/dev/null)" \
  || echo "browser-agents: agent-browser-Installation fehlgeschlagen"
command -v mise >/dev/null && mise reshim >/dev/null 2>&1

if [ -n "$BROWSER" ]; then
  mkdir -p "$HOME/.agent-browser"
  [ -f "$HOME/.agent-browser/config.json" ] \
    || printf '{\n  "executablePath": "%s"\n}\n' "$BROWSER" > "$HOME/.agent-browser/config.json"
else
  agent-browser install >/dev/null 2>&1
fi

# Claude in Chrome aus — direkt in jeder Konfiguration, nicht über `claude`:
# ein gesetztes CLAUDE_CONFIG_DIR lenkte den Aufruf für ~/.claude.json sonst
# in ein imkr-Konto um.
if command -v jq >/dev/null; then
  for cfg in "$HOME/.claude.json" "$HOME"/.local/state/imkr/accounts/claude/*/.claude.json; do
    [ -f "$cfg" ] || continue
    tmp="$(mktemp "$cfg.XXXX")" && jq '.claudeInChromeDefaultEnabled = false' "$cfg" > "$tmp" && mv "$tmp" "$cfg" || rm -f "$tmp"
    echo "browser-agents: Claude in Chrome aus in $cfg"
  done
fi
exit 0
