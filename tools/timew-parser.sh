#!/bin/bash

# ⌚ Script to parse the TimeWarrior output. Used to display it in status bar

# TODO: Change path based on OS
TIMEW_OUTPUT=$(/usr/local/bin/timew | head -n 1)
TIME_OUTPUT=$(/usr/local/bin/timew | tail -n 1)

# Return default output if "Tracking" is not found
if [[ $TIMEW_OUTPUT == "There is no active time tracking." ]]; then
  echo "🕑"
  exit
fi

TITLE=$(echo "$TIMEW_OUTPUT" | cut -d '"' -f1 | cut -d ' ' -f2)
TYPE=$(echo "$TIMEW_OUTPUT" | cut -d '"' -f4)
SUBTYPE=$(echo "$TIMEW_OUTPUT" | cut -d '"' -f6)
TASK_TITLE=$(echo "$TIMEW_OUTPUT" | cut -d '"' -f2)
# Get task parts
FN_NUMBER=$(echo "$TASK_TITLE" | cut -d ' ' -f1)
TIME_SPENT=$(echo "$TIME_OUTPUT" | cut -d 'l' -f2 | tr -d ' ')

# Trim everything after FN number in the first quoted string if it is found
if [[ $TIMEW_OUTPUT =~ "FN" ]]; then
  echo "$TIME_SPENT $TYPE $SUBTYPE $TITLE $FN_NUMBER"
  exit
fi

# If we get here, then we are tracking a misc task
echo "$TIME_SPENT $TYPE $TASK_TITLE $TITLE"

