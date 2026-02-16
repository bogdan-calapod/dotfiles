#!/bin/bash

echo "=== Testing ncspot integration with sketchybar ==="

# Check if ncspot is running
if pgrep -q ncspot; then
    echo "✓ ncspot is running"
else
    echo "✗ ncspot is not running"
    exit 1
fi

# Check if media-control script is running
if pgrep -qf "media-control"; then
    echo "✓ media-control.sh is running"
else
    echo "✗ media-control.sh is not running"
fi

# Check ncspot socket
NCSPOT_RUNTIME=$(ncspot info 2>/dev/null | grep "USER_RUNTIME_PATH" | cut -d' ' -f2)
if [ -S "$NCSPOT_RUNTIME/ncspot.sock" ]; then
    echo "✓ ncspot socket exists at: $NCSPOT_RUNTIME/ncspot.sock"
else
    echo "✗ ncspot socket not found"
fi

# Test ncspot status
echo -e "\nCurrent ncspot status:"
echo "status" | nc -U "$NCSPOT_RUNTIME/ncspot.sock" 2>/dev/null | head -1 | jq '{title: .playable.title, artist: .playable.artists[0], mode: .mode | keys[0]}'

# Check recent debug logs
echo -e "\nRecent media control activity:"
tail -3 /tmp/media-control-debug.log 2>/dev/null || echo "No debug log found"

echo -e "\n=== Test complete ==="