-- =====================================================
--  Hyprland configuration (Lua)
-- =====================================================
--  Converted from the legacy hyprlang (.conf) setup.
--  Requires Hyprland >= 0.55 (hyprlang is deprecated in favor of Lua).
--  See https://wiki.hypr.land/Configuring/Start/
--
--  Files are split up and pulled in with require() below.
--  require("config/foo") maps to ~/.config/hypr/config/foo.lua
-- =====================================================

-- Environment variables (set these early, before the display server init)
require("config/env")

-- Monitors
require("monitors")

-- Workspaces
require("workspaces")

-- Autostart
require("config/autostart")

-- Decoration
require("config/decoration")

-- General (borders, gaps, layout) -- pulls colors from config/colors.lua
require("config/general")

-- Input
require("config/input")

-- Cursor
require("config/cursor")

-- Window rules
require("config/windowrules")

-- Keybinds
require("config/keymaps")

-- Animations (also re-enables blur)
require("config/animation")

-- Misc
hl.config({
    misc = {
        force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
    },
})
