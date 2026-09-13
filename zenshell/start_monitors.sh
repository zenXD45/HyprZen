#!/bin/bash
DIR="$HOME/.config/quickshell/dynamic-island"

# Kill existing monitors
pkill -f "battery_monitor.sh"
pkill -f "bluetooth_monitor.sh"
pkill -f "notification_monitor.py"
pkill -f "notification_monitor.sh"

sleep 1

# Start them in background with output redirected
nohup bash "$DIR/scripts/battery_monitor.sh" >/tmp/battery_mon.log 2>&1 &
nohup bash "$DIR/scripts/bluetooth_monitor.sh" >/tmp/bluetooth_mon.log 2>&1 &
nohup python3 "$DIR/scripts/notification_monitor.py" >/tmp/notification_mon.log 2>&1 &

echo "Monitors started successfully."
