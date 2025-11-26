#!/bin/bash

# media-control-wrapper.sh - Smart media control wrapper
# Routes commands to ncspot if active, otherwise uses system media-control

NCSPOT_CONTROL="/Users/bogdan/repos/misc/dotfiles/config/sketchybar/ncspot-control.sh"
SYSTEM_MEDIA_CONTROL="/opt/homebrew/bin/media-control"

# Check if ncspot is running and has active media
is_ncspot_active() {
    if [ -x "$NCSPOT_CONTROL" ]; then
        # Try to get status from ncspot
        status=$($NCSPOT_CONTROL status 2>/dev/null)
        if [ $? -eq 0 ] && echo "$status" | grep -v "No status available" >/dev/null; then
            return 0  # ncspot is active
        fi
    fi
    return 1  # ncspot not active
}

# Map media-control commands to ncspot commands
map_command() {
    case "$1" in
        "toggle-play-pause") echo "playpause" ;;
        "next-track") echo "next" ;;
        "previous-track") echo "previous" ;;
        "play") echo "play" ;;
        "pause") echo "pause" ;;
        *) echo "$1" ;;
    esac
}

# Main logic
if [ $# -eq 0 ]; then
    # No arguments, show help
    echo "Media Control Wrapper"
    echo "Routes commands to ncspot if active, otherwise uses system media-control"
    echo ""
    $SYSTEM_MEDIA_CONTROL
    exit 0
fi

case "$1" in
    "toggle-play-pause"|"next-track"|"previous-track"|"play"|"pause")
        if is_ncspot_active; then
            ncspot_command=$(map_command "$1")
            echo "Routing to ncspot: $ncspot_command"
            $NCSPOT_CONTROL "$ncspot_command"
        else
            echo "Routing to system media-control: $1"
            $SYSTEM_MEDIA_CONTROL "$@"
        fi
        ;;
    *)
        # For all other commands, just pass through to system media-control
        $SYSTEM_MEDIA_CONTROL "$@"
        ;;
esac