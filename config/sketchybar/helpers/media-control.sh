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
# Consolidates all jq calls into a single invocation to avoid spawning 5 processes per poll
parse_ncspot_json() {
  local json="$1"

  # Single jq call: validate JSON, extract all fields at once
  local parsed
  parsed=$(echo "$json" | jq -r '
    if type == "object" and has("playable") then
      [
        (.playable.title // ""),
        (.playable.artists[0] // ""),
        (if (.mode | keys[0]) == "Playing" then "true" else "false" end)
      ] | join("\t")
    elif type == "object" then
      "NO_TRACK"
    else
      "INVALID"
    end
  ' 2>/dev/null)

  case "$parsed" in
    INVALID)
      return 1
      ;;
    NO_TRACK)
      update_bar "" "" "false"
      return 0
      ;;
    *)
      local ncspot_title ncspot_artist ncspot_playing
      IFS=$'\t' read -r ncspot_title ncspot_artist ncspot_playing <<< "$parsed"
      if [ -n "$ncspot_title" ] && [ "$ncspot_title" != "null" ]; then
        update_bar "$ncspot_title" "$ncspot_artist" "$ncspot_playing"
      else
        update_bar "" "" "false"
      fi
      return 0
      ;;
  esac
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
# Note: ncspot is checked once at startup above; we do NOT re-check it on every stream
# event to avoid spawning jq processes inside a high-frequency event loop.
echo "Using media-control as media source"
media-control stream |
  while IFS= read -r line; do
    # Single jq call: extract all needed fields at once
    parsed=$(jq -r '
      if (.payload | length) == 0 then
        "EMPTY"
      else
        [
          (.payload.title // ""),
          (.payload.artist // ""),
          (if .payload.playing != null then (.payload.playing | tostring) else "" end)
        ] | join("\t")
      end
    ' <<<"$line" 2>/dev/null)

    if [ "$parsed" = "EMPTY" ] || [ -z "$parsed" ]; then
      update_bar "" "" "false"
    else
      IFS=$'\t' read -r new_title new_artist new_playing <<< "$parsed"
      update_bar "$new_title" "$new_artist" "$new_playing"
    fi
  done
