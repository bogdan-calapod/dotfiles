#!/bin/bash

# Test media event
sketchybar --trigger media_stream_changed \
  title="Test Song" \
  artist="Test Artist" \
  playing="true"

echo "Triggered test media event"

# Check current sketchybar query
sleep 1
echo "Current media items state:"
sketchybar --query media_title
sketchybar --query media_artist
sketchybar --query media_cover