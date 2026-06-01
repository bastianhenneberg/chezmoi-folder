#!/bin/bash
# Toggelt das Tastaturlayout deterministisch auf ALLEN Tastaturen gleichzeitig.
# Hintergrund: `switchxkblayout all next` wertet "next" pro Gerät aus und laeuft
# bei mehreren Tastaturen (intern + Corne + fcitx5) auseinander. `all <index>`
# mit fester Zahl setzt dagegen zuverlaessig alle auf denselben Stand.
# Layouts: 0 = us, 1 = de  (siehe ~/.config/hypr/input.conf -> kb_layout)

# Referenz egal welches Keyboard: per `all` sind ohnehin immer alle synchron.
current=$(hyprctl devices -j | jq -r '[.keyboards[].active_keymap] | first')

if [ "$current" = "English (US)" ]; then
  hyprctl switchxkblayout all 1   # -> de
else
  hyprctl switchxkblayout all 0   # -> us
fi
