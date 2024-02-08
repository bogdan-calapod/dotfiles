#!/bin/bash

# ⌚ Script to parse the TimeWarrior output. Used to display it in status bar

TIMEW_OUTPUT=$(timew | head -n 1)

# Return the output directly if "Tracking" is not found
if [[ $TIMEW_OUTPUT != *"Tracking"* ]]; then
  echo "$TIMEW_OUTPUT"
  exit
fi

TITLE=$(echo "$TIMEW_OUTPUT" | cut -d '"' -f1)
TYPE=$(echo "$TIMEW_OUTPUT" | cut -d '"' -f4)
SUBTYPE=$(echo "$TIMEW_OUTPUT" | cut -d '"' -f6)
TASK_TITLE=$(echo "$TIMEW_OUTPUT" | cut -d '"' -f2)

# Trim everything after FN number in the first quoted string if it is found
if [[ $TIMEW_OUTPUT =~ "FN" ]]; then
  # Get task parts
  FN_NUMBER=$(echo "$TASK_TITLE" | cut -d ' ' -f1)

  echo "$TITLE $TYPE | $SUBTYPE | $FN_NUMBER"
  exit
fi

# If we get here, then we are tracking a misc task
echo "$TITLE | $TASK_TITLE"

