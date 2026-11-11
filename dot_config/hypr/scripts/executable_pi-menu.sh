#!/usr/bin/env bash
# Main menu for the Pi (pimarchy-on-the-road), on SUPER + ALT + SPACE like the
# Omarchy menu on the laptop. Pimarchy has no root menu of its own, so this is a
# small rofi list of the same everyday entries.

set -u

scripts="$HOME/.config/hypr/scripts"
imkr="$HOME/.local/bin/imkr"
term=foot
command -v ghostty >/dev/null 2>&1 && term=ghostty

pick() { # prompt, entries on stdin
    rofi -dmenu -i -p "$1"
}

sure() {
    [ "$(printf 'No\nYes\n' | pick "$1?")" = "Yes" ]
}

system_menu() {
    case "$(printf '%s\n' "Lock" "Re-detect display" "Update Pimarchy" "Reload Hyprland + Waybar" \
        "Log out" "Restart" "Shut down" | pick "System")" in
        "Lock") swaylock -f ;;
        "Re-detect display") "$scripts/redetect-display.sh" ;;
        "Update Pimarchy") "$term" -e bash -lc 'pimarchy update; read -rp "Enter to close "' ;;
        "Reload Hyprland + Waybar") pimarchy reload ;;
        "Log out") sure "Log out" && loginctl terminate-session "${XDG_SESSION_ID:-}" ;;
        "Restart") sure "Restart" && systemctl reboot ;;
        "Shut down") sure "Shut down" && systemctl poweroff ;;
    esac
}

case "$(printf '%s\n' "Apps" "Terminal" "imkr on codingmachine" "imkr here" \
    "Browser" "Files" "Editor" "Activity" "Coding agent" "Keyboard layout" \
    "Key bindings" "System" | pick "Menu")" in
    "Apps") rofi -show drun ;;
    "Terminal") "$term" ;;
    "imkr on codingmachine") "$term" -e "$imkr" --host codingmachine ;;
    "imkr here") "$term" -e "$imkr" ;;
    "Browser") chromium ;;
    "Files") pifile ;;
    "Editor") zed ;;
    "Activity") foot --app-id btop -e btop ;;
    "Coding agent") pimarchy agent ;;
    "Keyboard layout") "$scripts/toggle-kb-layout.sh" ;;
    "Key bindings") pimarchy-keybindings ;;
    "System") system_menu ;;
esac
