#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Run the AppleScript to get detailed notification information
NOTIFICATION_DATA=$(osascript "$SCRIPT_DIR/get_notifications.applescript" 2>/dev/null)

# Check if we got valid data
if [[ -z "$NOTIFICATION_DATA" ]]; then
    echo "0"
    exit 0
fi

# Output the result (format: total_count|app1:count1,app2:count2,...)
echo "$NOTIFICATION_DATA"