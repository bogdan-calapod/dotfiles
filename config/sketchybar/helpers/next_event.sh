#!/bin/bash

# Get next event from icalbuddy with proper error handling
get_next_event() {
  # Try to get events for today first, then tomorrow if none today
  local events_today=$(icalbuddy -ea -n -nc -f -tf "%H:%M" eventsToday 2>/dev/null)

  if [[ -n "$events_today" ]]; then
    # Extract first event and its time using structured approach
    local event_info=$(echo "$events_today" | grep -A1 -E "^[^[:space:]]" | head -2)
    if [[ -n "$event_info" ]]; then
      local event_title=$(echo "$event_info" | head -1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/.*• //')
      local event_time=$(echo "$event_info" | tail -1 | grep -o "[0-9][0-9]:[0-9][0-9] - [0-9][0-9]:[0-9][0-9]" | head -1)

      if [[ -n "$event_title" && -n "$event_time" ]]; then
        # Clean up the event title - remove ANSI codes and extra whitespace
        event_title=$(echo "$event_title" | sed 's/\[[0-9;]*m//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

        # Format: "Title (HH:MM-HH:MM)"
        local formatted_time=$(echo "$event_time" | sed 's/ - /-/')
        local result="$event_title ($formatted_time)"

        # Limit total length to fit in status bar
        if [[ ${#result} -gt 60 ]]; then
          local title_limit=$((65 - ${#formatted_time}))
          event_title="${event_title:0:$title_limit}..."
          result="$event_title ($formatted_time)"
        fi

        echo "$result"
        return
      fi
    fi
  fi

  # If no events today, try tomorrow
  local events_tomorrow=$(icalbuddy -n -nc -f -tf "%H:%M" eventsFrom:tomorrow to:tomorrow 2>/dev/null)
  if [[ -n "$events_tomorrow" ]]; then
    local event_info=$(echo "$events_tomorrow" | grep -A1 -E "^[^[:space:]]" | head -2)
    if [[ -n "$event_info" ]]; then
      local event_title=$(echo "$event_info" | head -1 | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//' | sed 's/.*• //')
      local event_time=$(echo "$event_info" | tail -1 | grep -o "[0-9][0-9]:[0-9][0-9] - [0-9][0-9]:[0-9][0-9]" | head -1)

      if [[ -n "$event_title" && -n "$event_time" ]]; then
        event_title=$(echo "$event_title" | sed 's/\[[0-9;]*m//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        local formatted_time=$(echo "$event_time" | sed 's/ - /-/')
        local result="→ $event_title ($formatted_time)"

        if [[ ${#result} -gt 30 ]]; then
          local title_limit=$((22 - ${#formatted_time}))
          event_title="${event_title:0:$title_limit}..."
          result="→ $event_title ($formatted_time)"
        fi

        echo "$result"
        return
      fi
    fi
  fi

  # No events found
  echo ""
}

# Execute and return result
get_next_event

