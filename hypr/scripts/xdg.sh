sleep 1

# kill all possible running xdg-desktop-portals
killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal
sleep 1

# start xdg-desktop-portal-hyprland
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2

# start xdg-desktop-portal
/usr/lib/xdg-desktop-portal &
sleep 1
