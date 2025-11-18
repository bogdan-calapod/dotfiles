#!/bin/bash
echo "=== Testing media-control stream for 3 seconds ==="
media-control stream &
PID=$!
sleep 3
kill $PID 2>/dev/null
wait $PID 2>/dev/null
echo "=== Test completed ==="
