-- AppleScript to get detailed notification information from dock applications
-- Returns JSON-like format: total_count|app1:count1,app2:count2,...

on run
    set totalNotifications to 0
    set appNotifications to {}
    
    tell application "System Events"
        -- Get the dock process
        tell process "Dock"
            try
                -- Get all dock items (applications)
                set dockApps to list 1
                tell dockApps
                    set appItems to UI elements
                    repeat with appItem in appItems
                        try
                            -- Check if there's a badge (notification indicator)
                            set badgeValue to value of attribute "AXStatusLabel" of appItem
                            if badgeValue is not missing value and badgeValue is not "" then
                                -- Get app name from the title
                                set appName to ""
                                try
                                    set appName to value of attribute "AXTitle" of appItem
                                on error
                                    set appName to "Unknown"
                                end try
                                
                                -- Try to convert badge to number, if it fails count as 1
                                set badgeCount to 0
                                try
                                    set badgeCount to badgeValue as integer
                                on error
                                    -- Badge exists but is not a number (e.g., "•"), count as 1
                                    set badgeCount to 1
                                end try
                                
                                set totalNotifications to totalNotifications + badgeCount
                                
                                -- Add to our list of apps with notifications
                                set end of appNotifications to (appName & ":" & badgeCount)
                            end if
                        on error
                            -- No badge or error accessing badge
                        end try
                    end repeat
                end tell
            on error
                -- Could not access dock items
            end try
        end tell
    end tell
    
    -- Format the output: total_count|app1:count1,app2:count2
    set output to totalNotifications as string
    if length of appNotifications > 0 then
        set AppleScript's text item delimiters to ","
        set appList to appNotifications as string
        set AppleScript's text item delimiters to ""
        set output to output & "|" & appList
    end if
    
    return output
end run