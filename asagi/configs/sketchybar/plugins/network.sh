#!/bin/bash

# Network Plugin
# Shows Wi-Fi connection status

# Detect Wi-Fi interface automatically
WIFI_DEVICE=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')

# Check if Wi-Fi interface is active
if ifconfig $WIFI_DEVICE 2>/dev/null | grep -q "status: active"; then
  # Get SSID from system_profiler
  SSID=$(system_profiler SPAirPortDataType 2>/dev/null | grep -A 1 "Current Network Information:" | grep -v "Current Network Information:" | grep ":" | head -1 | awk '{print $1}' | sed 's/:$//')

  if [ -z "$SSID" ]; then
    # If SSID can't be retrieved, just show as connected
    ICON="󰖩"
    LABEL="Connected"
  else
    ICON="󰖩"
    LABEL="$SSID"
  fi
else
  ICON="󰖪"
  LABEL="Disconnected"
fi

/opt/homebrew/opt/sketchybar/bin/sketchybar --set $NAME icon="$ICON" label="$LABEL"
