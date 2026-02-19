#!/bin/bash

show_help() {
    cat << 'EOF'
Usage: $(launch-gammastep "$0") [TEMPERATURE|off|--help|-h]

Set screen color temperature to reduce eye strain.

ARGUMENTS:
    TEMPERATURE     Desired color temperature in Kelvin (1-6500).
                    Values below 6500K reduce blue light (warmer/redder).
                    6500K is neutral daylight (no adjustment).
    off             Disable temperature adjustment (set to 6500K).
    --help, -h      Display this help message and exit.

DEFAULT BEHAVIOR:
    Without arguments, sets temperature to 3500K (warm evening light).

EXAMPLES:
    $(launch-gammastep "$0")              # Set to default 3500K
    $(launch-gammastep "$0") 2700         # Set to warm candlelight (2700K)
    $(launch-gammastep "$0") 4500         # Set to neutral warm white (4500K)
    $(launch-gammastep "$0") off          # Disable color adjustment (6500K)

RANGE:
    1K      Very warm/red (minimal blue light)
    2700K   Incandescent bulb warmth
    3500K   Default warm white
    4500K   Neutral white
    5500K   Cool white
    6500K   Daylight (no redshift)

REQUIREMENTS:
    - gammastep must be installed
    - set coordinates (latitude,longitude) inside the script

EOF
}

# Show help only when explicitly requested
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Set coodinates e.g. for Paris 48.8575, 2.3514
LAT=48.8575
LON=2.3514

# Default temperature
DEFAULT_TEMP=3500
MIN_TEMP=1
MAX_TEMP=6500

# Determine target temperature
if [[ $# -eq 0 ]]; then
    TARGET=$DEFAULT_TEMP
elif [[ "$1" == "off" ]]; then
    echo "Resetting screen colors..."
    # Reset gamma for all connected monitors
    for output in $(xrandr | grep " connected" | awk '{print $1}'); do
        xrandr --output $output --gamma 1:1:1
    done
    # Now kill the process
    killall gammastep 2>/dev/null
    echo "Night light turned off. Reverting to day light 6500 Kelvin"
    exit 0
elif [[ "$1" =~ ^[0-9]+$ ]]; then
    if [[ "$1" -lt "$MIN_TEMP" || "$1" -gt "$MAX_TEMP" ]]; then
        echo "Error: Temperature must be between $MIN_TEMP and $MAX_TEMP" >&2
        exit 1
    fi
    TARGET=$1
else
    echo "Error: Invalid argument '$1'" >&2
    echo "Use -h or --help for usage information" >&2
    exit 1
fi

# Apply temperature
# Kill existing instances to prevent conflicts
killall gammastep 2>/dev/null

# Run with Daylight (6500K) and user provided Target temperature ($1)
echo "Setting screen temperature to $TARGET Kelvin..."
gammastep -l $LAT:$LON -t 6500:$TARGET -v &
