#!/bin/bash

# CPU Plugin
# Shows CPU usage percentage

CPU_USAGE=$(top -l 2 -n 0 -F | grep "CPU usage" | tail -1 | awk '{print $3}' | cut -d% -f1)

sketchybar --set $NAME label="${CPU_USAGE}%"
