-- Autostart
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
-- hl.exec_cmd() spawns an async process (no need for "& disown").

hl.on("hyprland.start", function()
	-- Setup XDG for screen sharing
	hl.exec_cmd("~/.config/hypr/scripts/xdg.sh")

	-- Start Polkit
	-- hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("/usr/lib/polkit-kde-authentication-agent-1")

	-- Load Dunst Notification Manager
	hl.exec_cmd("dunst")

	-- Load GTK settings
	hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")

	-- Load network manager applet
	hl.exec_cmd("nm-applet --indicator")

	-- Load cliphist history
	hl.exec_cmd("wl-paste --watch cliphist store")

	-- Load waybar
	hl.exec_cmd("~/.config/waybar/launch.sh")

	-- Set wallpaper
	hl.exec_cmd("hyprpaper")

	-- Automount disks
	hl.exec_cmd("udiskie -s --mount-options sync")

	-- Cursor
	hl.exec_cmd("hyprctl setcursor 'Twilight Cursors' 24")

	-- Portal
	-- hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME")

	-- Keyring
	hl.exec_cmd("~/.config/hypr/scripts/keyring.sh")
end)
