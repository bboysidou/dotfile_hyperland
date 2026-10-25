-- Keybinds
-- https://wiki.hypr.land/Configuring/Basics/Binds/

-- Programs
local hasTerminal, chosenTerminal = pcall(require, "config/terminal")
local terminal = hasTerminal and chosenTerminal or "kitty"
local terminalExecFlags = { kitty = "", foot = "", alacritty = " -e", ghostty = " -e" }
local browser = "zen-browser"
local browser_alt = "brave"

local appScope = "systemd-run --user --scope --collect --quiet --slice=app.slice -- "

local function inTerminal(command)
  return terminal .. (terminalExecFlags[terminal] or " -e") .. " " .. command
end

local function launchApp(command)
  return hl.dsp.exec_cmd(appScope .. command)
end

-- Main modifier (SUPER / "Windows" key)
local mainMod = "SUPER"

-- MY STUFF ------------------------------------------------------------------
hl.bind("CTRL + SHIFT + F", launchApp(inTerminal("yazi")))
hl.bind(mainMod .. " + CTRL + F", launchApp(inTerminal("sh $HOME/.config/custom_scripts/tmux_resurect_session.sh")))
hl.bind("ALT + S", hl.dsp.global("quickshell:keybinds"))
hl.bind(mainMod .. " + C", launchApp(inTerminal("sh $HOME/.config/custom_scripts/ssh_connection.sh")))
hl.bind(mainMod .. " + X", hl.dsp.global("quickshell:power"))
hl.bind("ALT + C", hl.dsp.global("quickshell:controlcenter-network"))
hl.bind(mainMod .. " + CTRL + W", launchApp(inTerminal("sh $HOME/.config/custom_scripts/tmux_sessionizer.sh")))
hl.bind("ALT + W", hl.dsp.global("quickshell:wallpaper-picker"))
hl.bind("ALT + T", hl.dsp.global("quickshell:theme-picker"))
hl.bind(mainMod .. " + P", hl.dsp.global("quickshell:screenshot"))
hl.bind("ALT + V", hl.dsp.global("quickshell:controlcenter-audio"))
hl.bind("ALT + N", hl.dsp.global("quickshell:controlcenter-notifications"))
hl.bind("ALT + U", hl.dsp.global("quickshell:updates"))
hl.bind("ALT + B", hl.dsp.global("quickshell:controlcenter-bluetooth"))
hl.bind("ALT + P", hl.dsp.global("quickshell:controlcenter-power"))
hl.bind("ALT + D", hl.dsp.global("quickshell:display"))
hl.bind(mainMod .. " + Print", hl.dsp.global("quickshell:screenshot"))
hl.bind(mainMod .. " + SHIFT + B", hl.dsp.exec_cmd("systemctl --user restart quickshell.service"))
hl.bind(mainMod .. " + CTRL + X", hl.dsp.global("quickshell:lock"))
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("$HOME/.config/hypr/scripts/simplemode.sh"))
hl.bind(mainMod .. " + V", hl.dsp.global("quickshell:clipboard"))

-- Applications --------------------------------------------------------------
hl.bind(mainMod .. " + F", launchApp("thunar"))
hl.bind(mainMod .. " + Return", launchApp(terminal))
hl.bind(mainMod .. " + B", launchApp(browser))
hl.bind(mainMod .. " + CTRL + B", launchApp(browser_alt))
hl.bind(mainMod .. " + R", hl.dsp.global("quickshell:launcher"))
hl.bind("ALT + M", hl.dsp.global("quickshell:dashboard"))

-- Windows -------------------------------------------------------------------
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("~/dotfiles/hypr/scripts/toggleallfloat.sh"))
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Move / resize with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize the active window
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 5, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.resize({ x = -5, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.resize({ x = 0, y = -5, relative = true }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.resize({ x = 0, y = 5, relative = true }))

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
-- Which monitor each workspace lives on comes from workspaces.lua, which the
-- Quickshell display panel writes (focus the monitor, then the workspace).
local wsMonitor = require("workspaces")

for i = 1, 10 do
	local key = i % 10 -- workspace 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, function()
		if hl.get_monitor(wsMonitor[i]) then
			hl.dispatch(hl.dsp.focus({ monitor = wsMonitor[i] }))
		end
		hl.dispatch(hl.dsp.focus({ workspace = i }))
	end)
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Fn / media keys -----------------------------------------------------------
-- locked    = still fires while the lock screen is up
-- repeating = holding the key repeats the action
local held = { locked = true, repeating = true }
local locked = { locked = true }

hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -c backlight -q s +10%"), held)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -c backlight -q s 10%-"), held)

-- wpctl throughout (was a pactl/wpctl mix); -l 1 caps the sink at 100%
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), locked)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), locked)

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), locked)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl pause"), locked)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), locked)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), locked)
hl.bind("XF86Calculator", launchApp("qalculate-gtk"))
hl.bind("XF86PowerOff", hl.dsp.global("quickshell:power"))
