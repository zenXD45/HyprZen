#!/bin/bash
QS_PATH="/home/zen/.config/quickshell/dynamic-island"
BAT_PATH=$(upower -e | grep 'battery' | head -n 1)

if [ -z "$BAT_PATH" ]; then
    exit 1
fi

PREV_STATUS=$(upower -i $BAT_PATH | grep 'state:' | awk '{print $2}')
PREV_CAPACITY=$(upower -i $BAT_PATH | grep 'percentage:' | awk '{print $2}' | tr -d '%')

stdbuf -oL upower -m | while read -r line; do
    if [[ "$line" == *"battery"* || "$line" == *"line-power"* || "$line" == *"AC"* ]]; then
        STATUS=$(upower -i $BAT_PATH | grep 'state:' | awk '{print $2}')
        CAPACITY=$(upower -i $BAT_PATH | grep 'percentage:' | awk '{print $2}' | tr -d '%')
        
        if [ "$STATUS" != "$PREV_STATUS" ]; then
            if [[ "$STATUS" == "charging" || "$STATUS" == "fully-charged" ]]; then
                quickshell ipc -p "$QS_PATH" call battery showBattery "$CAPACITY" "true"
            else
                quickshell ipc -p "$QS_PATH" call battery showBattery "$CAPACITY" "false"
            fi
            PREV_STATUS=$STATUS
        fi
        
        if [ "$STATUS" == "discharging" ] && [ "$CAPACITY" != "$PREV_CAPACITY" ]; then
            if [ "$CAPACITY" == "20" ] || [ "$CAPACITY" == "10" ] || [ "$CAPACITY" == "5" ]; then
                quickshell ipc -p "$QS_PATH" call battery showBattery "$CAPACITY" "false"
            fi
            PREV_CAPACITY=$CAPACITY
        fi
    fi
done
