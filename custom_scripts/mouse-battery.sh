#!/bin/bash

# Check if Solaar is installed
if ! command -v solaar &> /dev/null; then
    echo '{"text": "Solaar not found", "tooltip": "Please install Solaar", "class": "error"}'
    exit 1
fi

# Get battery information from Solaar
battery_info=$(solaar show 2>/dev/null | grep -i battery | awk -F'[:,]' '{print $1 " " $2}' | sed 's/Battery//')
mouse_info=$(solaar show 2>/dev/null | grep -i Codename | awk -F'[:,]' '{print $1 " " $2}' | sed 's/Codename//'| sed 's/^[[:space:]]*//')

# If no battery info is found
if [ -z "$battery_info" ]; then
    echo '{"text": "No devices", "tooltip": "No Logitech devices found or Solaar not running", "class": "warning"}'
    exit 0
fi

# Format the output for Waybar
formatted_info=""
tooltip=""
lowest_battery=""
lowest_percentage=101

# Process each line of battery info
while IFS= read -r line; do
    # Extract device name and battery percentage
    device=$(echo "$line" | awk '{$NF=""; print $0}' | sed 's/^ *//;s/ *$//')
    percentage=$(echo "$line" | awk '{print $NF}' | tr -d '%')
    
    # Add to tooltip
    if [ -n "$tooltip" ]; then
        tooltip="$tooltip\n$device: $percentage%"
    else
        tooltip="$device: $percentage%"
    fi
    
    # Track lowest battery
    if [ -n "$percentage" ] && [ "$percentage" -lt "$lowest_percentage" ]; then
        lowest_percentage=$percentage
        lowest_battery="$device: $percentage%"
    fi
done <<< "$battery_info"

# Set class based on battery level
class="normal"
if [ "$lowest_percentage" -le 20 ]; then
    class="critical"
elif [ "$lowest_percentage" -le 40 ]; then
    class="warning"
fi

# Final output for Waybar
echo "{\"text\": \"🖱️${mouse_info} | ${lowest_percentage}%\", \"tooltip\": \"$tooltip\", \"class\": \"$class\"}"
