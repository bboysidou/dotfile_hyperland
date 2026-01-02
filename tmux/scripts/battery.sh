#!/bin/sh

get_battery_color() {
    if [ -f /sys/class/power_supply/BAT0/capacity ]; then
        capacity=$(cat /sys/class/power_supply/BAT0/capacity)
        status=$(cat /sys/class/power_supply/BAT0/status)
        
        if [ $capacity -lt 15 ]; then
            color="#[fg=#f44747]"
        elif [ $capacity -lt 30 ]; then
            color="#[fg=#d7ba7d]"
        elif [ $capacity -lt 50 ]; then
            color="#[fg=#ffd700]"
        else
            color="#[fg=#4ec9b0]"
        fi
        
        if [ "$status" = "Charging" ]; then
            if [ $capacity -gt 95 ]; then
                icon="󰂅"
            elif [ $capacity -gt 85 ]; then
                icon="󰂋"
            elif [ $capacity -gt 75 ]; then
                icon="󰂊"
            elif [ $capacity -gt 65 ]; then
                icon="󰢞"
            elif [ $capacity -gt 55 ]; then
                icon="󰂉"
            elif [ $capacity -gt 45 ]; then
                icon="󰢝"
            elif [ $capacity -gt 35 ]; then
                icon="󰂈"
            elif [ $capacity -gt 25 ]; then
                icon="󰂇"
            elif [ $capacity -gt 15 ]; then
                icon="󰂆"
            elif [ $capacity -gt 5 ]; then
                icon="󰢜"
            else
                icon="󰢜"
            fi
        else
            if [ $capacity -gt 95 ]; then
                icon="󰁹"
            elif [ $capacity -gt 90 ]; then
                icon="󰂂"
            elif [ $capacity -gt 80 ]; then
                icon="󰂁"
            elif [ $capacity -gt 70 ]; then
                icon="󰂀"
            elif [ $capacity -gt 60 ]; then
                icon="󰁿"
            elif [ $capacity -gt 50 ]; then
                icon="󰁾"
            elif [ $capacity -gt 40 ]; then
                icon="󰁽"
            elif [ $capacity -gt 30 ]; then
                icon="󰁼"
            elif [ $capacity -gt 20 ]; then
                icon="󰁻"
            elif [ $capacity -gt 10 ]; then
                icon="󰁺"
            else
                icon="󰂎"
            fi
        fi
        
        if [ "$status" = "Charging" ]; then
            charge_indicator=" ⚡"
        else
            charge_indicator=""
        fi
        
        echo "${color}${icon}#[fg=default] ${capacity}%${charge_indicator}"
    else
        echo "#[fg=#808080]󰚥#[fg=default] --"
    fi
}

get_battery_color
