#!/bin/bash

show_help() {
    cat << 'EOF'
Usage: $(tile-corners.sh "$0") [[l|r|tl|tr|bl|br|--help|-h]

ARGUMENTS:
    TILEMODE Tile active window on screen as per option [[l|r|tl|tr|bl]
        l       Tile left
        r       Tile right
        tl      Tile top left
        tr      Tile top right
        bl      Tile bottom left
        br      Tile bottom right
    --help, -h  Display this help message and exit.

EXAMPLE:
    $(tile-corners.sh bl)    # Tile active window to bottom left of screen
EOF
}

# Get screen dimensions
SCREEN_WIDTH=$(xdotool getdisplaygeometry | awk '{print $1}')
SCREEN_HEIGHT=$(xdotool getdisplaygeometry | awk '{print $2}')

# Calculate half width and height
HALF_WIDTH=$((SCREEN_WIDTH / 2))
HALF_HEIGHT=$((SCREEN_HEIGHT / 2))

# Get active window ID
WINDOW_ID=$(xdotool getactivewindow)

# Get window decorations (title bar and borders) height
DECORATIONS=$(xwininfo -id $WINDOW_ID | grep "Height:" | awk '{print $2}')
DECORATIONS_HEIGHT=$(($DECORATIONS - $(xwininfo -id $WINDOW_ID | grep "Height:" | awk '{print $2}')))

# Adjust height for bottom tiling to account for decorations
ADJUSTED_HEIGHT=$((HALF_HEIGHT - DECORATIONS_HEIGHT))

# Tile to left half
if [ "$1" == "l" ]; then
    xdotool windowsize $WINDOW_ID $HALF_WIDTH $SCREEN_HEIGHT
    xdotool windowmove $WINDOW_ID 0 0
# Tile to right half
elif [ "$1" == "r" ]; then
    xdotool windowsize $WINDOW_ID $HALF_WIDTH $SCREEN_HEIGHT
    xdotool windowmove $WINDOW_ID $HALF_WIDTH 0
# Tile to top-left
elif [ "$1" == "tl" ]; then
    xdotool windowsize $WINDOW_ID $HALF_WIDTH $HALF_HEIGHT
    xdotool windowmove $WINDOW_ID 0 0
# Tile to top-right
elif [ "$1" == "tr" ]; then
    xdotool windowsize $WINDOW_ID $HALF_WIDTH $HALF_HEIGHT
    xdotool windowmove $WINDOW_ID $HALF_WIDTH 0
# Tile to bottom-left
elif [ "$1" == "bl" ]; then
    xdotool windowsize $WINDOW_ID $HALF_WIDTH $ADJUSTED_HEIGHT
    xdotool windowmove $WINDOW_ID 0 $HALF_HEIGHT
# Tile to bottom-right
elif [ "$1" == "br" ]; then
    xdotool windowsize $WINDOW_ID $HALF_WIDTH $ADJUSTED_HEIGHT
    xdotool windowmove $WINDOW_ID $HALF_WIDTH $HALF_HEIGHT
else
    #echo "Usage: $0 [l|r|tl|tr|bl|br]"
    show_help
    exit 0
fi