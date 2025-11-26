#!/bin/bash

# media-key-monitor.sh - Monitor for media key presses and route to ncspot

echo "Media Key Monitor started - Press media keys to test..."
echo "Press Ctrl+C to stop"

# Create a named pipe for communication
PIPE_NAME="/tmp/media-key-monitor-$$"
mkfifo "$PIPE_NAME"

# Cleanup function
cleanup() {
    echo "Cleaning up..."
    rm -f "$PIPE_NAME"
    exit 0
}
trap cleanup INT TERM EXIT

# Monitor for media-control calls
echo "Monitoring media-control calls..."
echo "Try pressing your media keys now..."

# This is a simple approach - we'll enhance it based on what we find
while true; do
    read line < "$PIPE_NAME"
    case "$line" in
        "play"|"pause"|"playpause"|"next"|"previous")
            echo "Detected media command: $line"
            /Users/bogdan/repos/misc/dotfiles/config/sketchybar/ncspot-control.sh "$line"
            ;;
    esac
done &

# Keep the script running
wait