#!/usr/bin/env bash
while true; do
  hyprctl clients -j > /tmp/qs_clients.json
  timeout 1 swaync-client -c > /tmp/qs_notifs.json 2>/dev/null || echo '{"notifications":[]}' > /tmp/qs_notifs.json
  sleep 1
done
