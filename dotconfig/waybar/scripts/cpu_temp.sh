#!/bin/bash

# Pega a temperatura do sensor k10temp
temp=$(sensors | awk '/Tctl:/ {gsub(/\+|°C/,"",$2); print $2; exit}')

# Define classe conforme a temperatura
if (( $(echo "$temp >= 80" | bc -l) )); then
    class="critical"
elif (( $(echo "$temp >= 60" | bc -l) )); then
    class="warning"
else
    class="normal"
fi

# Retorna JSON pro Waybar:
# - text: só o ícone
# - tooltip: a string que aparecerá no hover
echo "{\"text\": \"\", \"tooltip\": \"CPU at ${temp}°C\", \"class\": \"${class}\"}"

