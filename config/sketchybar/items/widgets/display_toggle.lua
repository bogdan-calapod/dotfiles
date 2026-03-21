local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Track current display mode: "all" or "main"
local display_mode = "all"

local display_toggle = sbar.add("item", "widgets.display_toggle", {
	position = "right",
	icon = {
		string = icons.display.all,
		color = colors.white,
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
	},
	label = {
		drawing = false,
	},
	background = {
		color = colors.transparent,
		border_width = 0,
	},
})

sbar.add("item", "widgets.display_toggle.padding", {
	position = "right",
	width = settings.group_paddings,
})

local function toggle_display_mode()
	if display_mode == "all" then
		-- Switch to main display only
		display_mode = "main"
		sbar.bar({
			display = "main",
		})
		display_toggle:set({
			icon = {
				string = icons.display.main,
				color = colors.grey,
			},
		})
	else
		-- Switch to all displays
		display_mode = "all"
		sbar.bar({
			display = "all",
		})
		display_toggle:set({
			icon = {
				string = icons.display.all,
				color = colors.white,
			},
		})
	end
end

display_toggle:subscribe("mouse.clicked", toggle_display_mode)
