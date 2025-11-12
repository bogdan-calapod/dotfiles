#!/bin/bash

# Get next event from icalbuddy with proper error handling
get_next_event() {
  # Get current time in minutes since midnight for comparison
  local current_hour=$(date +%H)
  local current_minute=$(date +%M)
  local current_minutes=$(($current_hour * 60 + $current_minute))
  
  # Try to get events for today first
  local events_today=$(icalbuddy -ea -nc -n -f -tf "%H:%M" eventsToday 2>/dev/null)

  if [[ -n "$events_today" ]]; then
    local event_title=""
    local best_event=""
    local best_time=""
    local best_start_minutes=99999
    local is_current=false
    
    while IFS= read -r line; do
      # Check if this is an event title line
      if [[ $line =~ •.*$ ]]; then
        event_title=$(echo "$line" | sed 's/.*• //' | sed 's/\[[0-9;]*m//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
      # Check if this is a time line
      elif [[ $line =~ [0-9][0-9]:[0-9][0-9].*-.*[0-9][0-9]:[0-9][0-9] ]]; then
        local time_match=$(echo "$line" | grep -o '[0-9][0-9]:[0-9][0-9] - [0-9][0-9]:[0-9][0-9]')
        if [[ -n "$time_match" ]]; then
          local start_time=$(echo "$time_match" | cut -d' ' -f1)
          local end_time=$(echo "$time_match" | cut -d' ' -f3)
          
          # Convert times to minutes for comparison
          local start_hour=${start_time%:*}
          local start_minute=${start_time#*:}
          local start_minutes=$(($start_hour * 60 + $start_minute))
          
          local end_hour=${end_time%:*}
          local end_minute=${end_time#*:}
          local end_minutes=$(($end_hour * 60 + $end_minute))
          
          # Check if this event is currently happening
          if [[ $start_minutes -le $current_minutes && $current_minutes -lt $end_minutes ]]; then
            # Current ongoing event - this takes priority
            best_event="$event_title"
            best_time="$start_time-$end_time"
            is_current=true
            break
          # Check if this event is upcoming and better than our current best
          elif [[ $start_minutes -gt $current_minutes && $start_minutes -lt $best_start_minutes ]]; then
            best_event="$event_title"
            best_time="$start_time-$end_time"
            best_start_minutes=$start_minutes
            is_current=false
          fi
        fi
      fi
    done <<< "$events_today"
    
    # Format the result if we found an event
    if [[ -n "$best_event" && -n "$best_time" ]]; then
      local prefix=""
      if [[ $is_current == true ]]; then
        prefix="🔴 "  # Red circle for current event
      fi
      
      local result="$prefix$best_event ($best_time)"
      
      # Limit total length to fit in status bar
      if [[ ${#result} -gt 50 ]]; then
        local title_limit=$((45 - ${#best_time} - ${#prefix}))
        best_event="${best_event:0:$title_limit}..."
        result="$prefix$best_event ($best_time)"
      fi
      
      echo "$result"
      return
    fi
  fi

  # If no events today, try tomorrow
  local events_tomorrow=$(icalbuddy -nc -f -tf "%H:%M" eventsFrom:tomorrow to:tomorrow 2>/dev/null)
  if [[ -n "$events_tomorrow" ]]; then
    local event_title=""
    local event_time=""
    
    while IFS= read -r line; do
      if [[ $line =~ •.*$ ]]; then
        event_title=$(echo "$line" | sed 's/.*• //' | sed 's/\[[0-9;]*m//g' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
      elif [[ $line =~ [0-9][0-9]:[0-9][0-9].*-.*[0-9][0-9]:[0-9][0-9] ]]; then
        local time_match=$(echo "$line" | grep -o '[0-9][0-9]:[0-9][0-9] - [0-9][0-9]:[0-9][0-9]')
        if [[ -n "$time_match" ]]; then
          event_time=$(echo "$time_match" | sed 's/ - /-/')
          break  # Take the first event tomorrow
        fi
      fi
    done <<< "$events_tomorrow"
    
    if [[ -n "$event_title" && -n "$event_time" ]]; then
      local result="→ $event_title ($event_time)"
      
      if [[ ${#result} -gt 40 ]]; then
        local title_limit=$((35 - ${#event_time}))
        event_title="${event_title:0:$title_limit}..."
        result="→ $event_title ($event_time)"
      fi
      
      echo "$result"
      return
    fi
  fi

  # No events found
  echo ""
}

# Execute and return result
get_next_event