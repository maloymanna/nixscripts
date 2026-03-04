#!/bin/bash

# Set DISPLAY and DBUS_SESSION_BUS_ADDRESS for GUI applications
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

# Run the Sublime Text plugin to switch themes
# subl --command "switch_theme"

# Define Sublime Text settings file path
SUBLIME_SETTINGS="$HOME/.config/sublime-text/Packages/User/Preferences.sublime-settings"

# Sublime themes and color schemes
DAY_THEME="Adaptive.sublime-theme"
DAY_COLOR_SCHEME="Celeste.sublime-color-scheme"
NIGHT_THEME="Adaptive.sublime-theme"
NIGHT_COLOR_SCHEME="Monokai.sublime-color-scheme"

# XFCE theme configuration
LIGHT_THEME="Materia-light"
DARK_THEME="Materia-dark"
XFCE_SETTING="/Net/ThemeName"

# Get current theme
CURRENT_THEME=$(xfconf-query -c xsettings -p $XFCE_SETTING 2>/dev/null)

# Check if xfconf-query exists
if ! command -v xfconf-query &> /dev/null; then
    echo "Error: xfconf-query not found. Are you running XFCE?"
    exit 1
fi

# Toggle logic
if [ "$CURRENT_THEME" == "$DARK_THEME" ] || [[ "$CURRENT_THEME" == *"dark"* ]] || [[ "$CURRENT_THEME" == *"Dark"* ]]; then
    # Switch to dark
       sed -i 's/"theme": ".*"/"theme": "'"$NIGHT_THEME"'"/' "$SUBLIME_SETTINGS"
       sed -i 's/"color_scheme": ".*"/"color_scheme": "'"$NIGHT_COLOR_SCHEME"'"/' "$SUBLIME_SETTINGS"
else
    # Switch to light
    sed -i 's/"theme": ".*"/"theme": "'"$DAY_THEME"'"/' "$SUBLIME_SETTINGS"
    sed -i 's/"color_scheme": ".*"/"color_scheme": "'"$DAY_COLOR_SCHEME"'"/' "$SUBLIME_SETTINGS"
fi
