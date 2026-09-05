-- Autostart
-- https://wiki.hypr.land/Configuring/Basics/Autostart/
-- hl.exec_cmd() spawns an async process (no need for "& disown").

hl.on("hyprland.start", function()
	-- Setup XDG for screen sharing
	hl.exec_cmd("~/.config/hypr/scripts/xdg.sh")

	-- Load GTK settings
	hl.exec_cmd("~/.config/hypr/scripts/gtk.sh")

	-- Load cliphist history
	hl.exec_cmd("wl-paste --watch cliphist store")

	-- Load Quickshell shell (replaces waybar and dunst)
	hl.exec_cmd("qs -d -n")

	-- Automount disks
	hl.exec_cmd("udiskie -s")

	-- Cursor
	hl.exec_cmd("hyprctl setcursor 'Bibata-Modern-Ice' 24")

	-- Portal
	-- hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user import-environment QT_QPA_PLATFORMTHEME")

	-- Keyring
	hl.exec_cmd("~/.config/hypr/scripts/keyring.sh")
end)
