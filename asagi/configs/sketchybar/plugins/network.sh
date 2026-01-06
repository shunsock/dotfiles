#!/bin/bash

# Network Plugin
# Shows Wi-Fi connection status

# Get Wi-Fi SSID
SSID=$(networksetup -getairportnetwork en0 | sed 's/Current Wi-Fi Network: //')

if [[ $SSID == "You are not associated with an AirPort network."* ]]; then
  ICON="󰖪"
  LABEL="Disconnected"
else
  ICON="󰖩"
  LABEL="$SSID"
fi

/opt/homebrew/opt/sketchybar/bin/sketchybar --set $NAME icon="$ICON" label="$LABEL"
