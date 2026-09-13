#!/bin/bash
TYPE=$1
ACTION=$2
QS_PATH="/home/zen/.config/quickshell/dynamic-island"

if [ "$TYPE" == "volume" ]; then
    if [ "$ACTION" == "up" ]; then
        wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
    elif [ "$ACTION" == "down" ]; then
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    elif [ "$ACTION" == "mute" ]; then
        wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    elif [ "$ACTION" == "mic-mute" ]; then
        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        TYPE="mic"
    fi
    
    if [ "$TYPE" == "volume" ]; then
        quickshell ipc -p /home/zen/.config/quickshell/dynamic-island call osd showVolume
    else
        quickshell ipc -p /home/zen/.config/quickshell/dynamic-island call osd showMic
    fi
    
elif [ "$TYPE" == "brightness" ]; then
    if [ "$ACTION" == "up" ]; then
        brightnessctl set 5%+
    elif [ "$ACTION" == "down" ]; then
        brightnessctl set 5%-
    fi
    
    quickshell ipc -p /home/zen/.config/quickshell/dynamic-island call osd showBrightness
fi
