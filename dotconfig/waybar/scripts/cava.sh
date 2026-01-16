#!/usr/bin/env bash
set -euo pipefail

BARS=20
LEVELS=("▁" "▂" "▃" "▄" "▅" "▆" "▇" "█")

# Run Cava with inline config
stdbuf -oL cava -p <(cat <<EOF
[general]
bars = ${BARS}

[input]
method = pulse
source = auto

[output]
method = raw
channels = mono
data_format = ascii
ascii_max_range = 7
bar_delimiter   = 32
frame_delimiter = 10
EOF
) | while IFS=$' ' read -r -a nums; do
  # Check if the default sink is muted
  MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
  if [ "$MUTED" = "yes" ]; then
    # Output empty bars when muted
    empty=$(printf '%0.s▁' $(seq 1 $BARS))
    echo "{\"text\":\"$empty\",\"class\":\"cava\"}"
    sleep 0.1
    continue
  fi

  # Build the bar line
  visual=""
  for n in "${nums[@]}"; do
    (( n < 0 )) && n=0
    (( n > 7 )) && n=7
    visual+="${LEVELS[$n]}"
  done

  # Output for Waybar
  echo "{\"text\":\"$visual\",\"class\":\"cava\"}"
done

