#!/bin/bash

# Ensure PATH includes homebrew
export PATH="/opt/homebrew/bin:$PATH"

title=""
artist=""
playing="false"

# Get ncspot runtime path
NCSPOT_SOCK=""
if command -v ncspot >/dev/null 2>&1; then
  NCSPOT_RUNTIME=$(ncspot info 2>/dev/null | grep "USER_RUNTIME_PATH" | cut -d' ' -f2)
  if [ -n "$NCSPOT_RUNTIME" ] && [ -S "$NCSPOT_RUNTIME/ncspot.sock" ]; then
    NCSPOT_SOCK="$NCSPOT_RUNTIME/ncspot.sock"
  fi
fi

update_bar() {
  local new_title="$1"
  local new_artist="$2" 
  local new_playing="$3"
  
  if [ -n "$new_title" ] && [ "$new_title" != "null" ] && [ "$new_title" != "" ]; then
    title="$new_title"
  fi
  if [ -n "$new_artist" ] && [ "$new_artist" != "null" ] && [ "$new_artist" != "" ]; then
    artist="$new_artist"
  fi
  if [ -n "$new_playing" ] && [ "$new_playing" != "null" ] && [ "$new_playing" != "" ]; then
    playing="$new_playing"
  fi

  echo "$(date): title: $title, artist: $artist, playing: $playing" >> /tmp/media-control-debug.log
  sketchybar --trigger media_stream_changed title="$title" artist="$artist" playing="$playing"
}

get_ncspot_status() {
  if [ -n "$NCSPOT_SOCK" ]; then
    # Send status command and read response
    echo "status" | nc -U "$NCSPOT_SOCK" 2>/dev/null | head -1
  fi
}

# Function to parse ncspot JSON and extract info
parse_ncspot_json() {
  local json="$1"
  
  # First check if it's valid JSON
  if ! echo "$json" | jq -e . >/dev/null 2>&1; then
    return 1
  fi
  
  # Check if we have playable data
  local has_playable=$(echo "$json" | jq -r 'has("playable")')
  if [ "$has_playable" != "true" ]; then
    # No track playing, clear the display
    update_bar "" "" "false"
    return 0
  fi
  
  local ncspot_title=$(echo "$json" | jq -r '.playable.title // empty')
  local ncspot_artist=$(echo "$json" | jq -r '.playable.artists[0] // empty')
  local mode=$(echo "$json" | jq -r '.mode | keys[0] // empty' 2>/dev/null)
  local ncspot_playing="false"
  
  if [ "$mode" = "Playing" ]; then
    ncspot_playing="true"
  fi
  
  if [ -n "$ncspot_title" ] && [ "$ncspot_title" != "null" ] && [ "$ncspot_title" != "empty" ]; then
    update_bar "$ncspot_title" "$ncspot_artist" "$ncspot_playing"
    return 0
  else
    # No valid title, clear display
    update_bar "" "" "false"
    return 0
  fi
}

# Try ncspot first if available
if [ -n "$NCSPOT_SOCK" ]; then
  ncspot_status=$(get_ncspot_status)
  if parse_ncspot_json "$ncspot_status"; then
    echo "Using ncspot as media source"
    # Start monitoring ncspot changes (simplified approach - just poll periodically)
    while true; do
      sleep 2
      ncspot_status=$(get_ncspot_status)
      if [ -z "$ncspot_status" ]; then
        # No response from ncspot
        echo "No response from ncspot, falling back"
        title=""
        artist=""
        playing="false" 
        update_bar "" "" "false"
        break
      fi
      if ! parse_ncspot_json "$ncspot_status"; then
        # Failed to parse, but maybe still running
        echo "Failed to parse ncspot response: $ncspot_status" >&2
        continue
      fi
    done
  fi
fi

# Fall back to media-control streaming if ncspot is not available or stopped
echo "Using media-control as media source"
media-control stream |
  while IFS= read -r line; do
    # Skip if we have active ncspot
    if [ -n "$NCSPOT_SOCK" ]; then
      ncspot_status=$(get_ncspot_status)
      if parse_ncspot_json "$ncspot_status"; then
        continue  # Skip media-control if ncspot is active
      fi
    fi
    
    diff=$(jq -r '.diff' <<<"$line")

    payload_empty=$(jq -r 'if (.payload | length) == 0 then "true" else "false" end' <<<"$line")
    #empty payload means no media is playing/paused
    if [ "$payload_empty" = "true" ]; then
      update_bar "" "" "false"
    else
      new_title=$(jq -r 'if .payload.title then .payload.title else empty end' <<<"$line")
      new_artist=$(jq -r 'if .payload.artist then .payload.artist else empty end' <<<"$line") 
      new_playing=$(jq -r 'if .payload.playing != null then .payload.playing else empty end' <<<"$line")

      update_bar "$new_title" "$new_artist" "$new_playing"
    fi
  done
