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

-- XREAL One Pro, set by what the glasses offer right now (their own menu
-- switches 16:9 and 32:9). 16:9: 1920x1080@60; they take 120, but Bastian
-- found 60 calmer (half the signal through the adapter chain, same as 32:9).
-- 32:9: 3840x1080@60 only (their EDID caps HDMI at 340 MHz) at scale 1.25;
-- at scale 1 the glasses' resampling onto their 1080p panels shows as moire.
-- 16:9 is the TV mode 1080p60 with 8 more pixels per line (59.98 Hz): the
-- kernel sends TV modes in limited RGB range (16-235), which made colours and
-- black look washed out; any other timing gets full range.
-- Modelines (timings from their EDID) instead of mode names: Hyprland keeps
-- the mode list from its start, so after a switch the new mode is not in it.
-- The menu's "Re-detect display" re-reads the port and reloads this file.
local function hdmi_modes()
    local p = io.popen("cat /sys/class/drm/card*-HDMI-A-1/modes 2>/dev/null")
    if not p then return "" end
    local modes = p:read("*a") or ""
    p:close()
    return modes
end
local ultrawide = hdmi_modes():find("3840x1080", 1, true) ~= nil
hl.monitor({
    output = "desc:Nreal XREAL One Pro",
    mode = ultrawide
        and "modeline 297.00 3840 4016 4104 4400 1080 1084 1089 1125 +hsync +vsync"
        or "modeline 149.04 1920 2008 2052 2208 1080 1084 1089 1125 +hsync +vsync",
    position = "auto",
    scale = ultrawide and 1.25 or 1,
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
