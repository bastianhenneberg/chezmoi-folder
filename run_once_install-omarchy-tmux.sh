#!/bin/bash
# omarchy-tmux plugin installer
# Source: https://github.com/joaofelipegalvao/omarchy-tmux
# Idempotent — only installs if not already present.
set -e

PLUGIN_DIR="$HOME/.config/tmux/plugins/omarchy-tmux"
THEME_SET_BIN="$HOME/.local/bin/omarchy-tmux-theme-set"

if [ ! -d "$PLUGIN_DIR/.git" ]; then
  mkdir -p "$(dirname "$PLUGIN_DIR")"
  git clone https://github.com/joaofelipegalvao/omarchy-tmux "$PLUGIN_DIR"
fi

# Upstream restrukturiert: Installer liegt jetzt unter install.sh (Root),
# erzeugt ~/.local/bin/omarchy-tmux-theme-set als bleibendes Artefakt.
if [ ! -f "$THEME_SET_BIN" ]; then
  bash "$PLUGIN_DIR/install.sh"
fi
