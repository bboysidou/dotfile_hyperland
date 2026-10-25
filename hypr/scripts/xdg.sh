#!/usr/bin/env bash
sleep 1
pkill -f '^/usr/lib/xdg-desktop-portal-hyprland$'
pkill -f '^/usr/lib/xdg-desktop-portal$'
systemctl --user restart xdg-desktop-portal-hyprland xdg-desktop-portal
