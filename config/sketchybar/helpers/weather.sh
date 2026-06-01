#!/bin/bash

# Fetch current weather from wttr.in using IP-based geolocation.
# Output format (single line): CONDITION_KEY|TEMP
# Where CONDITION_KEY is one of:
#   sunny, night, partly_cloudy, cloudy, rainy, pouring,
#   snowy, fog, lightning, unknown
# and TEMP is the temperature string (e.g. "22°C") or empty on failure.

CACHE_FILE="${TMPDIR:-/tmp}/sketchybar_weather_cache"
CACHE_TTL=900 # seconds (15 min) — separate from sketchybar update_freq

# Serve from cache if fresh
if [[ -f "$CACHE_FILE" ]]; then
  age=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0)))
  if [[ $age -lt $CACHE_TTL ]]; then
    cat "$CACHE_FILE"
    exit 0
  fi
fi

# %t = temperature, %C = condition text; separated by | for safe parsing
RESPONSE=$(curl -fsS --max-time 5 "https://wttr.in/?format=%t|%C" 2>/dev/null)

if [[ -z "$RESPONSE" || "$RESPONSE" == *"Unknown location"* ]]; then
  # Keep stale cache visible if we have one; otherwise emit empty
  if [[ -f "$CACHE_FILE" ]]; then
    cat "$CACHE_FILE"
  else
    echo "unknown|"
  fi
  exit 0
fi

TEMP=$(echo "$RESPONSE" | cut -d'|' -f1 | tr -d '+ ')
COND=$(echo "$RESPONSE" | cut -d'|' -f2- | tr '[:upper:]' '[:lower:]')

# Map wttr.in condition phrases to our icon keys.
# wttr.in conditions: https://github.com/chubin/wttr.in
case "$COND" in
  *thunder*|*lightning*)             KEY="lightning" ;;
  *blizzard*|*snow*|*sleet*|*ice*)   KEY="snowy" ;;
  *heavy*rain*|*pouring*|*torrent*)  KEY="pouring" ;;
  *rain*|*shower*|*drizzle*)         KEY="rainy" ;;
  *fog*|*mist*|*haze*|*smoke*)       KEY="fog" ;;
  *overcast*|*cloudy*)               KEY="cloudy" ;;
  *partly*|*partial*)                KEY="partly_cloudy" ;;
  *clear*|*sunny*|*fair*)
    HOUR=$(date +%H)
    if [[ "$HOUR" -ge 19 || "$HOUR" -lt 6 ]]; then
      KEY="night"
    else
      KEY="sunny"
    fi
    ;;
  *) KEY="unknown" ;;
esac

OUT="$KEY|$TEMP"
echo "$OUT" | tee "$CACHE_FILE"
