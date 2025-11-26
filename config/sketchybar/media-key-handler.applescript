-- media-key-handler.applescript
-- Handles media key events and routes them to ncspot

on run argv
    set command to item 1 of argv
    
    if command is "playpause" then
        do shell script "/Users/bogdan/repos/misc/dotfiles/config/sketchybar/ncspot-control.sh playpause"
    else if command is "next" then
        do shell script "/Users/bogdan/repos/misc/dotfiles/config/sketchybar/ncspot-control.sh next"
    else if command is "previous" then
        do shell script "/Users/bogdan/repos/misc/dotfiles/config/sketchybar/ncspot-control.sh previous"
    end if
end run