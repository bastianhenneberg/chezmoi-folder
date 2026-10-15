#!/usr/bin/env bash
# Browser-Werkzeuge für Coding-Agenten, unabhängig vom Claude-Account:
#   - agent-browser (Vercel): CLI, der Agent ruft es per Bash auf
#   - Playwright MCP: Standard für UI-Tests und Flows
#   - Chrome DevTools MCP: Console, Network, Performance, Lighthouse
# Registriert die MCPs in jedem imkr-Claude-Account, im Standard-Claude-Config und in Codex.
# Idempotent; läuft erneut, sobald sich diese Datei ändert.
set -u

command -v npm >/dev/null || { echo "browser-agents: npm fehlt, übersprungen"; exit 0; }

BROWSER="$(command -v chromium || command -v google-chrome-stable || command -v google-chrome || true)"

# agent-browser (ohne root: bei schreibgeschütztem npm-Prefix nach ~/.local)
NPM_PREFIX=()
[ -w "$(npm config get prefix)/lib" ] || NPM_PREFIX=(--prefix "$HOME/.local")
npm i -g "${NPM_PREFIX[@]}" --allow-scripts=agent-browser agent-browser@latest >/dev/null 2>&1 \
  && echo "browser-agents: $(agent-browser --version 2>/dev/null)" \
  || echo "browser-agents: agent-browser-Installation fehlgeschlagen"
command -v mise >/dev/null && mise reshim >/dev/null 2>&1

if [ -n "$BROWSER" ]; then
  mkdir -p "$HOME/.agent-browser"
  [ -f "$HOME/.agent-browser/config.json" ] \
    || printf '{\n  "executablePath": "%s"\n}\n' "$BROWSER" > "$HOME/.agent-browser/config.json"
  PW_ARGS=(--executable-path "$BROWSER")
  DT_ARGS=(--executablePath "$BROWSER")
else
  agent-browser install >/dev/null 2>&1
  PW_ARGS=()
  DT_ARGS=()
fi

# MCPs in Claude Code (alle imkr-Accounts + Standard-Config)
if command -v claude >/dev/null; then
  dirs=("")
  for d in "$HOME"/.local/state/imkr/accounts/claude/*/; do
    [ -d "$d" ] && dirs+=("${d%/}")
  done
  for d in "${dirs[@]}"; do
    env=()
    [ -n "$d" ] && env=(CLAUDE_CONFIG_DIR="$d")
    env "${env[@]}" claude mcp get playwright >/dev/null 2>&1 \
      || env "${env[@]}" claude mcp add -s user playwright -- npx -y @playwright/mcp@latest "${PW_ARGS[@]}" >/dev/null 2>&1
    env "${env[@]}" claude mcp get chrome-devtools >/dev/null 2>&1 \
      || env "${env[@]}" claude mcp add -s user chrome-devtools -- npx -y chrome-devtools-mcp@latest "${DT_ARGS[@]}" >/dev/null 2>&1
    echo "browser-agents: Claude ${d:-~/.claude} eingerichtet"
  done
fi

# MCPs in Codex
if command -v codex >/dev/null; then
  codex mcp get playwright >/dev/null 2>&1 \
    || codex mcp add playwright -- npx -y @playwright/mcp@latest "${PW_ARGS[@]}" >/dev/null 2>&1
  codex mcp get chrome-devtools >/dev/null 2>&1 \
    || codex mcp add chrome-devtools -- npx -y chrome-devtools-mcp@latest "${DT_ARGS[@]}" >/dev/null 2>&1
  echo "browser-agents: Codex eingerichtet"
fi
exit 0
