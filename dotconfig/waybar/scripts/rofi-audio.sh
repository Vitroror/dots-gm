#!/bin/bash
# Rofi Audio Device Switcher with Friendly Names

# Get sinks with both name + description
SINKS=$(pactl list short sinks | awk '{print $1, $2}')
DEFAULT=$(pactl get-default-sink)

# Build menu: show description, but keep sink name hidden in selection
MENU=""
while read -r INDEX NAME; do
    DESC=$(pactl list sinks | grep -A 20 "$NAME" | grep "Description:" | sed 's/^[[:space:]]*Description: //')
    if [ "$NAME" = "$DEFAULT" ]; then
        MENU+=" $DESC [$NAME]\n"
    else
        MENU+="    $DESC [$NAME]\n"
    fi
done <<< "$SINKS"

# Show in rofi
CHOSEN=$(echo -e "$MENU" | rofi -dmenu -i -p "Audio Output")

[ -z "$CHOSEN" ] && exit

# Extract sink name from selection
CHOSEN_SINK=$(echo "$CHOSEN" | sed -E 's/.*\[(.*)\]$/\1/')

# Set default sink
pactl set-default-sink "$CHOSEN_SINK"

# Move all playing streams to new sink
for input in $(pactl list short sink-inputs | awk '{print $1}'); do
  pactl move-sink-input "$input" "$CHOSEN_SINK"
done

notify-send "Audio" "Switched to $(echo "$CHOSEN" | sed -E 's/\s*\[.*\]//')"

