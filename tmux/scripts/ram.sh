#!/bin/sh
# Get RAM values
read -r _ total used _ <<< $(free -h | grep '^Mem:')

# Clean up the values (remove spaces, Gi/Mi markers)
total_clean=$(echo "$total" | sed 's/Gi/G/;s/Mi/M/')
used_clean=$(echo "$used" | sed 's/Gi/G/;s/Mi/M/')

# Calculate percentage for coloring
read -r _ total_m used_m _ <<< $(free | grep '^Mem:')
percent=$((used_m * 100 / total_m))

# Output (tmux will apply colors from status-left config)
echo "󰍛 ${used_clean}/${total_clean}"
