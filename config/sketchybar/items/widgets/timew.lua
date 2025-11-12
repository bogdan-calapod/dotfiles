local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Create a timew widget that updates every 10 seconds
local timew = sbar.add("item", "widgets.timew", {
	position = "right",
	background = {
		height = 22,
		color = {
			alpha = 0,
		},
		border_color = {
			alpha = 0,
		},
		drawing = true,
	},
	icon = {
		string = "⌚",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Bold"],
			size = 12.0,
		},
		color = colors.blue,
		padding_left = 8,
		padding_right = 4,
	},
	label = {
		string = "Loading...",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 12.0,
		},
		color = colors.white,
		padding_right = 8,
	},
	padding_right = settings.paddings,
})

-- Function to update timew display
local function update_timew()
	sbar.exec("~/repos/misc/dotfiles/tools/timew-parser.sh", function(result)
		local output = result:gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
		
		if output == "🕑" then
			-- No active time tracking
			timew:set({
				icon = {
					string = "🕑",
					color = colors.grey,
				},
				label = {
					string = "No tracking",
					color = colors.grey,
				},
			})
		else
			-- Active time tracking - parse the output
			timew:set({
				icon = {
					string = "⌚",
					color = colors.green,
				},
				label = {
					string = output,
					color = colors.white,
				},
			})
		end
	end)
end

-- Initial update
update_timew()

-- Set up timer to update every 10 seconds
sbar.exec("sleep 10 && while true; do sleep 10; sketchybar --trigger timew_update; done &")

-- Subscribe to the update event
timew:subscribe("timew_update", function(env)
	update_timew()
end)

-- Optional: Click to open timewarrior or show more info
timew:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a Terminal && sleep 0.5 && osascript -e 'tell application \"Terminal\" to do script \"timew\"'")
end)

-- Background bracket around the timew item
sbar.add("bracket", "widgets.timew.bracket", { timew.name }, {
	background = {
		color = colors.transparent,
		border_color = colors.transparent,
		border_width = 1,
	},
})

-- Padding after the timew item
sbar.add("item", "widgets.timew.padding", {
	position = "right",
	width = settings.group_paddings,
})