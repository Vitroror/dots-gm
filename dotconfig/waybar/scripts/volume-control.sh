#!/bin/bash

# Define a tag para o SwayNC atualizar a notificação existente em vez de criar novas
TAG="sys-notify"

# Função para enviar a notificação
send_notification() {
    # Pega o volume atual
    vol=$(pamixer --get-volume)
    # Pega o status de mudo
    mute=$(pamixer --get-mute)
    
    if [ "$mute" == "true" ]; then
        icon="audio-volume-muted"
        text="Muted"
    else
        icon="audio-volume-high"
        text="Volume: ${vol}%"
    fi

    # Envia a notificação com a barra de progresso (value:vol)
    notify-send -h string:x-canonical-private-synchronous:$TAG \
                -h int:value:$vol \
                -u low \
                -i "$icon" \
                "$text"
}

case $1 in
    up)
        # Aumenta volume
        pactl set-sink-volume @DEFAULT_SINK@ +1%
        send_notification
        ;;
    down)
        # Diminui volume
        pactl set-sink-volume @DEFAULT_SINK@ -1%
        send_notification
        ;;
    mute)
        # Toggle Mute
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        send_notification
        ;;
esac
