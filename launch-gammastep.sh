#!/bin/bash

# Set coodinates e.g. for Paris 48.8575, 2.3514
LAT=48.8575
LON=2.3514

# Handle "off" command
if [ "$1" == "off" ]; then
    echo "Resetting screen colors..."
    # Reset gamma for all connected monitors
    for output in $(xrandr | grep " connected" | awk '{print $1}'); do
        xrandr --output $output --gamma 1:1:1
    done
    # Now kill the process
    killall gammastep 2>/dev/null
    echo "Night light turned off. Reverting to day light 6500 Kelvin"
    exit 0
fi

# Set temperature: Default to 3500, otherwise use the first argument
# ${1:-3500} means: Use $1 if provided, otherwise default to 3500
TEMP=${1:-3500}

# Kill existing instances to prevent conflicts
killall gammastep 2>/dev/null

# Run with Day (6500K) and User-Defined Night Temp ($1)
echo "Setting night temperature to $TEMP Kelvin..."
gammastep -l $LAT:$LON -t 6500:$TEMP -v &

