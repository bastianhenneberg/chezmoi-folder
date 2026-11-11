-- Bastian's keys on top of Pimarchy, so the Pi feels like the Omarchy laptop.
-- Loaded last from hyprland.lua (require("hypr.bastian")); Pimarchy's own
-- bindings.lua stays untouched, so `pimarchy update` can keep refreshing it.
-- Source of truth for the habits: ~/.config/hypr/bindings.lua on the laptop
-- (Omarchy defaults plus Bastian's overrides). Managed by chezmoi (machine "pi").

local home = os.getenv("HOME") or ""
local imkr = home .. "/.local/bin/imkr"
local scripts = home .. "/.config/hypr/scripts"

local function exec(command)
    return hl.dsp.exec_cmd(command)
end

local function bind(keys, description, dispatcher)
    hl.unbind(keys)
    hl.bind(keys, dispatcher, { description = description })
end

-- Keyboard as on the desktop: US first, German one SUPER + SPACE away,
-- Compose on Caps Lock. Overrides Pimarchy's kb_layout = "de"; the rest of its
-- input block (repeat rate, numlock, touchpad) stays.
hl.config({
    input = {
        kb_layout = "us,de",
        kb_options = "compose:caps",
    },
})

-- Pimarchy keys that mean something else on the laptop
hl.unbind("SUPER + W") -- Pimarchy: close window (laptop: SUPER + Q)
hl.unbind("SUPER + J") -- Pimarchy: toggle split (laptop: SUPER + SHIFT + Z)
hl.unbind("SUPER + K") -- Pimarchy: keybindings (laptop: SUPER + I)
hl.unbind("SUPER + V") -- Pimarchy: float (laptop: SUPER + T)

-- Windows
bind("SUPER + Q", "Close window", hl.dsp.window.close())
bind("SUPER + T", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + SHIFT + Z", "Toggle window split", hl.dsp.layout("togglesplit"))
bind("SUPER + G", "Toggle window grouping", hl.dsp.group.toggle())
bind("SUPER + ALT + G", "Move active window out of group", hl.dsp.window.move({ out_of_group = true }))
bind("ALT + TAB", "Focus on next window", hl.dsp.window.cycle_next())
bind("ALT + SHIFT + TAB", "Focus on previous window", hl.dsp.window.cycle_next({ next = false }))

-- Vim-style focus and move, as on the laptop (arrow keys from Pimarchy stay)
bind("SUPER + H", "Move focus left", hl.dsp.focus({ direction = "l" }))
bind("SUPER + L", "Move focus right", hl.dsp.focus({ direction = "r" }))
bind("SUPER + K", "Move focus up", hl.dsp.focus({ direction = "u" }))
bind("SUPER + J", "Move focus down", hl.dsp.focus({ direction = "d" }))
bind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.move({ direction = "l" }))
bind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.move({ direction = "r" }))
bind("SUPER + SHIFT + K", "Move window up", hl.dsp.window.move({ direction = "u" }))
bind("SUPER + SHIFT + J", "Move window down", hl.dsp.window.move({ direction = "d" }))

bind("SUPER + SPACE", "Switch keyboard layout", exec(scripts .. "/toggle-kb-layout.sh"))

-- Workspaces and scratchpad
bind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
bind("SUPER + S", "Toggle scratchpad", hl.dsp.workspace.toggle_special("scratchpad"))
bind("SUPER + ALT + S", "Move window to scratchpad",
    hl.dsp.window.move({ workspace = "special:scratchpad", follow = false }))

-- Apps, on the laptop's keys
bind("SUPER + R", "Launch apps", exec("rofi -show drun"))
bind("SUPER + ALT + SPACE", "Main menu", exec(scripts .. "/pi-menu.sh"))
bind("SUPER + I", "Show key bindings", exec("pimarchy-keybindings"))
bind("SUPER + SHIFT + T", "Activity", exec("foot --app-id btop -e btop"))
bind("SUPER + SHIFT + F", "File manager", exec("pifile"))
bind("SUPER + SHIFT + N", "Editor", exec("zed"))
bind("SUPER + ESCAPE", "Lock screen", exec("swaylock -f"))

-- imkr: the work runs on the codingmachine, the Pi only shows it.
-- SUPER + ALT + RETURN is Tmux on the laptop, the same slot for the same habit.
bind("SUPER + ALT + RETURN", "imkr on codingmachine", exec("foot -e " .. imkr .. " --host codingmachine"))
bind("SUPER + CTRL + RETURN", "imkr here", exec("foot -e " .. imkr))
