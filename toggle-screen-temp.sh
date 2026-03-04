#!/usr/bin/env bash

STATE_FILE="$HOME/.gammastep_toggle_state"
DEFAULT_WARM=3500
DEFAULT_NORMAL=6500

# Function to apply temperature instantly
apply_temp() {
    pkill gammastep 2>/dev/null
    gammastep -O "$1" -P
}

# If argument is a number, apply directly
if [[ "$1" =~ ^[0-9]+$ ]]; then
    apply_temp "$1"
    echo "$1" > "$STATE_FILE"
    exit 0
fi

# Initialize state file if missing
if [ ! -f "$STATE_FILE" ]; then
    echo "$DEFAULT_NORMAL" > "$STATE_FILE"
fi

CURRENT=$(cat "$STATE_FILE")

case "$1" in
    on)
        apply_temp "$DEFAULT_WARM"
        echo "$DEFAULT_WARM" > "$STATE_FILE"
        ;;
    off)
        apply_temp "$DEFAULT_NORMAL"
        echo "$DEFAULT_NORMAL" > "$STATE_FILE"
        ;;
    *)
        # Toggle mode (no argument)
        if [ "$CURRENT" = "$DEFAULT_NORMAL" ]; then
            apply_temp "$DEFAULT_WARM"
            echo "$DEFAULT_WARM" > "$STATE_FILE"
        else
            apply_temp "$DEFAULT_NORMAL"
            echo "$DEFAULT_NORMAL" > "$STATE_FILE"
        fi
        ;;
esac
