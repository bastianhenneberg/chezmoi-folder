#!/bin/bash
# omarchy-tmux plugin installer
# Source: https://github.com/joaofelipegalvao/omarchy-tmux
# Idempotent — only installs if not already present.
set -e

PLUGIN_DIR="$HOME/.config/tmux/plugins/omarchy-tmux"
MONITOR_BIN="$HOME/.local/bin/omarchy-tmux-monitor"

if [ ! -d "$PLUGIN_DIR/.git" ]; then
  mkdir -p "$(dirname "$PLUGIN_DIR")"
  git clone https://github.com/joaofelipegalvao/omarchy-tmux "$PLUGIN_DIR"
fi

if [ ! -f "$MONITOR_BIN" ]; then
  bash "$PLUGIN_DIR/scripts/omarchy-tmux-install.sh" -q -f
fi
