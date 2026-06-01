local settings = require("settings")
local colors = require("colors")
local icons = require("icons")

-- Color tints per condition key
local condition_color = {
	sunny = colors.yellow,
	night = colors.magenta,
	partly_cloudy = colors.yellow,
	cloudy = colors.grey,
	rainy = colors.blue,
	pouring = colors.blue,
	snowy = colors.white,
	fog = colors.grey,
	lightning = colors.orange,
	unknown = colors.grey,
}

local weather = sbar.add("item", "widgets.weather", {
	position = "right",
	icon = {
		color = colors.yellow,
		padding_left = 8,
		padding_right = 4,
		font = {
			family = settings.nerd_font,
			size = 14.0,
		},
	},
	label = {
		color = colors.white,
		padding_right = 4,
		font = {
			family = settings.calendarfont,
			size = 12.0,
		},
	},
	update_freq = 1800, -- 30 min
	padding_left = 1,
	padding_right = 1,
	background = {
		color = colors.transparent,
		border_color = colors.transparent,
		border_width = 1,
	},
	click_script = "open -a 'Safari' https://wttr.in/",
})

weather:subscribe({ "forced", "routine", "system_woke" }, function()
	sbar.exec("/Users/bogdan/repos/misc/dotfiles/config/sketchybar/helpers/weather.sh", function(result)
		result = result or ""
		result = result:gsub("%s+$", "") -- trim trailing whitespace

		local key, temp = result:match("([^|]*)|(.*)")
		key = key or "unknown"
		temp = temp or ""

		if temp == "" then
			weather:set({ drawing = false })
			return
		end

		local icon_glyph = icons.weather[key] or icons.weather.unknown
		local color = condition_color[key] or colors.white

		weather:set({
			drawing = true,
			icon = {
				string = icon_glyph,
				color = color,
			},
			label = {
				string = temp,
			},
		})
	end)
end)

-- Padding so the weather widget sits visually next to the clock
sbar.add("item", "widgets.weather.padding", {
	position = "right",
	width = settings.group_paddings,
})
