sleep 1

# kill all possible running xdg-desktop-portals
killall -e xdg-desktop-portal-hyprland
killall -e xdg-desktop-portal-wlr
killall xdg-desktop-portal

# start xdg-desktop-portal-hyprland
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2

# start xdg-desktop-portal
/usr/lib/xdg-desktop-portal &
