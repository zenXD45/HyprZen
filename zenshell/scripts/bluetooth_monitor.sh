#!/bin/bash
QS_PATH="/home/zen/.config/quickshell/dynamic-island"

# Listen for BlueZ PropertiesChanged signals for devices
dbus-monitor --system "type='signal',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged',arg0='org.bluez.Device1'" | \
while read -r line; do
    if echo "$line" | grep -q 'string "Connected"'; then
        read -r val_line
        if echo "$val_line" | grep -q 'boolean true'; then
            # Wait a tiny bit for the connection to settle
            sleep 0.5
            
            # Fetch the name of the most recently connected device
            DEVICE_NAME=$(bluetoothctl devices Connected | head -n 1 | cut -d' ' -f3-)
            if [ -z "$DEVICE_NAME" ]; then
                DEVICE_NAME="Bluetooth Device"
            fi
            
            quickshell ipc -p "$QS_PATH" call bluetooth showDevice "$DEVICE_NAME"
        fi
    fi
done
