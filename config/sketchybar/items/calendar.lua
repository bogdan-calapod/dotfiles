local settings = require("settings")
local colors = require("colors")

-- Padding item required because of bracket
sbar.add("item", {
	position = "right",
	-- width = settings.group_paddings,
})

local cal = sbar.add("item", {
	icon = {
		color = colors.white,
		padding_left = 8,
		font = {
			size = 18.0,
		},
	},
	label = {
		color = colors.white,
		padding_right = 8,
		align = "right",
		font = {
			family = settings.calendarfont,
			size = 12.0,
		},
	},
	position = "right",
	update_freq = 30,
	padding_left = 1,
	padding_right = 1,
	background = {
		color = colors.transparent,
		border_color = colors.transparent,
		border_width = 1,
	},
})

-- Double border for calendar using a single item bracket
-- sbar.add("bracket", { cal.name }, {
--   background = {
--     color = colors.transparent,
--     height = 30,
--     border_color = colors.grey,
--   }
-- })

-- Padding item required because of bracket
sbar.add("item", {
	position = "right",
	width = settings.group_paddings,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
	-- Get current time
	local current_time = os.date("%H:%M")

	-- Get next event from helper script
	local handle = io.popen("/Users/bogdan/repos/misc/dotfiles/config/sketchybar/helpers/next_event.sh")
	local next_event = ""
	if handle then
		next_event = handle:read("*a") or ""
		next_event = string.gsub(next_event, "%s+$", "") -- trim trailing whitespace
		handle:close()
	end

	-- Format label: time + event (if any)
	local label_text = current_time
	if next_event ~= "" then
		label_text = current_time .. " • " .. next_event
	end

	cal:set({
		icon = "",
		label = label_text,
	})
end)
