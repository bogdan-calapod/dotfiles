#!/bin/bash

# ncspot-control.sh - Control ncspot via IPC socket
# Usage: ncspot-control.sh [play|pause|playpause|next|previous|status]

# Get ncspot runtime path - use absolute path for compatibility
NCSPOT_SOCK=""
NCSPOT_BIN="/opt/homebrew/bin/ncspot"
if [ -x "$NCSPOT_BIN" ]; then
  NCSPOT_RUNTIME=$($NCSPOT_BIN info 2>/dev/null | grep "USER_RUNTIME_PATH" | cut -d' ' -f2)
  if [ -n "$NCSPOT_RUNTIME" ] && [ -S "$NCSPOT_RUNTIME/ncspot.sock" ]; then
    NCSPOT_SOCK="$NCSPOT_RUNTIME/ncspot.sock"
  fi
fi

if [ -z "$NCSPOT_SOCK" ]; then
  echo "Error: ncspot is not running or socket not found"
  exit 1
fi

# Function to send command to ncspot
send_ncspot_command() {
  local command="$1"
  echo "$command" | nc -U "$NCSPOT_SOCK" 2>/dev/null >/dev/null
}

# Function to get ncspot status
get_ncspot_status() {
  echo "status" | nc -U "$NCSPOT_SOCK" 2>/dev/null | head -1
}

# Parse command line argument
case "${1:-}" in
  play)
    send_ncspot_command "play"
    echo "ncspot: play"
    ;;
  pause)
    send_ncspot_command "pause"
    echo "ncspot: pause"
    ;;
  playpause|toggle)
    send_ncspot_command "playpause"
    echo "ncspot: play/pause toggle"
    ;;
  next)
    send_ncspot_command "next"
    echo "ncspot: next track"
    ;;
  previous|prev)
    send_ncspot_command "previous"
    echo "ncspot: previous track"
    ;;
  status)
    status=$(get_ncspot_status)
    if [ -n "$status" ]; then
      title=$(echo "$status" | jq -r '.playable.title // "Unknown"')
      artist=$(echo "$status" | jq -r '.playable.artists[0] // "Unknown"')
      mode=$(echo "$status" | jq -r '.mode | keys[0] // "Unknown"')
      echo "ncspot: $title by $artist [$mode]"
    else
      echo "ncspot: No status available"
    fi
    ;;
  *)
    echo "Usage: $0 [play|pause|playpause|next|previous|status]"
    echo "Commands:"
    echo "  play      - Start playback"
    echo "  pause     - Pause playback"  
    echo "  playpause - Toggle play/pause"
    echo "  next      - Next track"
    echo "  previous  - Previous track"
    echo "  status    - Show current status"
    exit 1
    ;;
esac