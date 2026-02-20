#!/bin/bash

# Toggles screen temperature between warm and daylight
# Hardcoded coordinates e.g. for Paris
LATITUDE="48.8575"
LONGITUDE="2.3514"

# Temperatures
WARM_TEMP=3500
DAYLIGHT_TEMP=6500

# State file to track current mode (stored in /tmp or XDG_RUNTIME_DIR)
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/screentemp_toggle_state"

# Check current state and toggle
if [[ -f "$STATE_FILE" ]]; then
    current_temp=$(cat "$STATE_FILE")
else
    current_temp=$DAYLIGHT_TEMP
fi

# Toggle between states
if [[ "$current_temp" == "$WARM_TEMP" ]]; then
    target_temp=$DAYLIGHT_TEMP
else
    target_temp=$WARM_TEMP
fi

# Apply temperature using gammastep
# Kill existing gammastep instances first
pkill -x gammastep 2>/dev/null

# Run gammastep with hardcoded coordinates
gammastep -l "$LATITUDE:$LONGITUDE" -t "${DAYLIGHT_TEMP}:${target_temp}" &

# Save new state
echo "$target_temp" > "$STATE_FILE"

echo "Screen color temp set to ${target_temp}K"