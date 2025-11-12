local colors = require("colors")
local icons = require("icons")

return {
	paddings = 3,
	group_paddings = 5,
	modes = {
		main = {
			icon = icons.rebel,
			color = colors.rainbow[1],
		},
		service = {
			icon = icons.nuke,
			color = 0xffff9e64,
		},
	},
	bar = {
		height = 30,
		padding = {
			x = 10,
			y = 0,
		},
		background = colors.with_alpha(colors.bg1, 0.5),
	},
	items = {
		height = 18,
		gap = 5,
		padding = {
			right = 0,
			left = 12,
			top = 0,
			bottom = 0,
		},
		default_color = function(workspace)
			return colors.grey
		end,
		highlight_color = function(workspace)
			return colors.rainbow[4]
		end,
		colors = {
			background = colors.bg1,
		},
		corner_radius = 4,
	},

	icons = "sketchybar-app-font:Regular:12.0",
	nerd_font = "FiraCode Nerd Font Mono:Regular:16.0",
	calendarfont = "sketchybar-app-font:Regular:10.0",

	font = {
		text = "FiraCode Nerd Font Mono", -- Used for text
		numbers = "FiraCode Nerd Font Mono", -- Used for numbers
		style_map = {
			["Regular"] = "Regular",
			["Semibold"] = "Medium",
			["Bold"] = "SemiBold",
			["Heavy"] = "Bold",
			["Black"] = "ExtraBold",
		},
	},
}
