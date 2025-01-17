#!/bin/bash

# Read the wifi-mode alias from hyprlock.conf
show_ssid=$(awk -F'=' '/^\$wifi-mode/ {gsub(/[[:space:]]/, "", $2); print $2}' ~/.config/hypr/hyprlock.conf)

# Check if the username was successfully extracted
if [ -z "$show_ssid" ]; then
    echo "Username not found in hyprlock.conf."
    exit 1
fi

# Get connection states for Wi-Fi and Ethernet
wifi_status=$(nmcli -t -f WIFI g)
ethernet_status=$(nmcli -t -f DEVICE,STATE dev | awk -F: '$2 == "connected" && $1 ~ /eno1/ {print "connected"}')
wifi_connection_status=$(nmcli -t -f DEVICE,STATE dev | awk -F: '$2 == "connected" && $1 ~ /wlan/ {print "connected"}')
# If Ethernet is connected, prioritize it

# Check if Wi-Fi is enabled
if [ "$ethernet_status" = "connected" ]; then
    echo "󰈀 Eth Connected"
    exit 0
fi
if [ "$wifi_status" != "enabled" ]; then
    echo "󰤮 Wi-Fi Off"
    exit 0
elif
  [ "$wifi_connection_status" = "connected" ]; then
    echo "󰤥 Connected"
    exit 0
else
    echo "󰤮 Disconnected"
    exit 0
fi

# Get active Wi-Fi connection details
wifi_info=$(nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | awk -F: '$1 == "yes"')

# If no active connection, show "No Wi-Fi"
if [ -z "$wifi_info" ]; then
    echo "󰤮  No Wi-Fi"
    exit 0
fi

# Extract SSID and signal strength directly using awk
ssid=$(echo "$wifi_info" | awk -F: '{print $2}')
signal_strength=$(echo "$wifi_info" | awk -F: '{print $3}')

# Define Wi-Fi icons based on signal strength
wifi_icons=("󰤯" "󰤟" "󰤢" "󰤥" "󰤨") # From low to high signal

# Ensure signal_strength is within bounds (0 to 100)
signal_strength=$((signal_strength < 0 ? 0 : (signal_strength > 100 ? 100 : signal_strength)))

# Calculate the icon index based on signal strength (0–100 -> 0–4)
icon_index=$((signal_strength / 25))

# Get the corresponding icon
wifi_icon=${wifi_icons[$icon_index]}

# Output based on show_ssid variable
if [ "$ethernet_status" = "connected" ]; then
    echo "󰈀 Eth Connected"
else
    echo "$wifi_icon Connected"
fi
