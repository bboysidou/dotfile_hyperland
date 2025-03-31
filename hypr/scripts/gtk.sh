#!/bin/bash
# Source: https://github.com/swaywm/sway/wiki/GTK-3-settings-on-Wayland
#
gnome_schema="org.gnome.desktop.interface"
THEME='Graphite-teal-Dark'
# THEME='Juno-ocean'
ICON='kora-green'

gsettings set "$gnome_schema" gtk-theme "$THEME"
gsettings set "$gnome_schema" icon-theme "$ICON"
gsettings set "$gnome_schema" color-scheme "prefer-dark"
# gsettings set "$gnome_schema" cursor-theme "$cursor_theme"
# gsettings set "$gnome_schema" font-name "$font_name"

