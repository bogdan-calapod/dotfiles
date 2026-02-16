#!/bin/bash

# Log wrapper for media-control.sh
exec /Users/bogdan/repos/misc/dotfiles/config/sketchybar/helpers/media-control.sh 2>&1 | tee -a /tmp/media-control-wrapper.log