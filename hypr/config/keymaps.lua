-- Keybinds
-- https://wiki.hypr.land/Configuring/Basics/Binds/

-- Programs
local terminal    = "kitty"
local fileManager = "thunar"
local browser     = "zen-browser"
local browser_alt = "brave"

-- Main modifier (SUPER / "Windows" key)
local mainMod = "SUPER"

-- MY STUFF ------------------------------------------------------------------
hl.bind("CTRL + SHIFT + F",       hl.dsp.exec_cmd("kitty yazi"))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.exec_cmd("kitty sh $HOME/.config/custom_scripts/tmux_resurect_session.sh"))
hl.bind(mainMod .. " + S",        hl.dsp.exec_cmd("sh -c $HOME/.config/custom_scripts/auto_start_work.sh"))
hl.bind(mainMod .. " + C",        hl.dsp.exec_cmd("kitty sh $HOME/.config/custom_scripts/ssh_connection.sh"))
hl.bind(mainMod .. " + X",        hl.dsp.global("quickshell:power"))
hl.bind(mainMod .. " + W",        hl.dsp.global("quickshell:controlcenter-wifi"))
hl.bind(mainMod .. " + CTRL + W", hl.dsp.exec_cmd("kitty sh $HOME/.config/custom_scripts/tmux_sessionizer.sh"))
hl.bind("ALT + W",                hl.dsp.global("quickshell:wallpaper-picker"))
hl.bind(mainMod .. " + P",        hl.dsp.global("quickshell:screenshot"))
hl.bind(mainMod .. " + V",        hl.dsp.global("quickshell:controlcenter-audio"))
hl.bind(mainMod .. " + N",        hl.dsp.global("quickshell:controlcenter-toggle"))
hl.bind("ALT + B",                hl.dsp.global("quickshell:controlcenter-bluetooth"))
hl.bind(mainMod .. " + Print",    hl.dsp.global("quickshell:screenshot"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("sh -c 'qs kill; sleep 1; qs -d'"))
hl.bind(mainMod .. " + CTRL + X", hl.dsp.global("quickshell:lock"))
hl.bind(mainMod .. " + SHIFT + CTRL + X", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/simplemode.sh"))

-- Applications --------------------------------------------------------------
hl.bind(mainMod .. " + F",        hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + Return",   hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + B",        hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + CTRL + B", hl.dsp.exec_cmd(browser_alt))
hl.bind(mainMod .. " + R",        hl.dsp.global("quickshell:launcher"))
hl.bind(mainMod .. " + D",        hl.dsp.global("quickshell:dashboard"))

-- Windows -------------------------------------------------------------------
hl.bind(mainMod .. " + Q",         hl.dsp.window.close())
hl.bind(mainMod .. " + M",         hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + T",         hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/toggleallfloat.sh"))
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Move / resize with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize the active window
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x =  5, y =  0, relative = true }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -5, y =  0, relative = true }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x =  0, y = -5, relative = true }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x =  0, y =  5, relative = true }))

-- Move focus
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))

-- Move the active window
hl.bind(mainMod .. " + CTRL + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.window.move({ direction = "down" }))

-- Actions -------------------------------------------------------------------
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exit())

-- Workspaces ----------------------------------------------------------------
-- Which monitor each workspace lives on (legacy config focused the monitor
-- AND switched to the workspace on the same key; both are preserved here).
local wsMonitor = {
    "HDMI-A-1", "DP-3", "DP-3", "DP-3", "DP-3",
    "DP-3",     "DP-3", "DP-3", "DP-3", "DP-3",
}

for i = 1, 10 do
    local key = i % 10 -- workspace 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, function()
        hl.dispatch(hl.dsp.focus({ monitor = wsMonitor[i] }))
        hl.dispatch(hl.dsp.focus({ workspace = i }))
    end)
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Fn / media keys -----------------------------------------------------------
-- locked    = still fires while hyprlock is up
-- repeating = holding the key repeats the action
local held   = { locked = true, repeating = true }
local locked = { locked = true }

hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -c backlight -q s +10%"), held)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -c backlight -q s 10%-"), held)

-- wpctl throughout (was a pactl/wpctl mix); -l 1 caps the sink at 100%
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), locked)

hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl pause"), locked)
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"), locked)
hl.bind("XF86Calculator",        hl.dsp.exec_cmd("qalculate-gtk"))
