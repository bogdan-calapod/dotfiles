#!/bin/bash

echo "Starting media debug script..."

# Get ncspot runtime path
NCSPOT_SOCK=""
if command -v ncspot >/dev/null 2>&1; then
  NCSPOT_RUNTIME=$(ncspot info 2>/dev/null | grep "USER_RUNTIME_PATH" | cut -d' ' -f2)
  echo "NCSPOT_RUNTIME: $NCSPOT_RUNTIME"
  if [ -n "$NCSPOT_RUNTIME" ] && [ -S "$NCSPOT_RUNTIME/ncspot.sock" ]; then
    NCSPOT_SOCK="$NCSPOT_RUNTIME/ncspot.sock"
    echo "Found ncspot socket at: $NCSPOT_SOCK"
  fi
fi

# Test ncspot connection
if [ -n "$NCSPOT_SOCK" ]; then
  echo "Testing ncspot connection..."
  ncspot_status=$(echo "status" | nc -U "$NCSPOT_SOCK" 2>&1 | head -1)
  echo "Raw ncspot response: $ncspot_status"
  
  if echo "$ncspot_status" | jq -e . >/dev/null 2>&1; then
    echo "Valid JSON received"
    ncspot_title=$(echo "$ncspot_status" | jq -r '.playable.title // empty')
    ncspot_artist=$(echo "$ncspot_status" | jq -r '.playable.artists[0] // empty')
    mode=$(echo "$ncspot_status" | jq -r '.mode | keys[0] // empty')
    
    echo "Title: $ncspot_title"
    echo "Artist: $ncspot_artist"
    echo "Mode: $mode"
    
    # Trigger sketchybar update
    echo "Triggering sketchybar update..."
    sketchybar --trigger media_stream_changed title="$ncspot_title" artist="$ncspot_artist" playing="true"
    echo "Sketchybar trigger sent"
  else
    echo "Invalid JSON or no response"
  fi
else
  echo "No ncspot socket found"
fi