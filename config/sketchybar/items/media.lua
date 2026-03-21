local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Simple media widget using media-control (same info as macOS Control Center)

local media_artist = sbar.add("item", "media.artist", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "",
		font = { size = 9 },
		color = colors.with_alpha(colors.white, 0.6),
		max_chars = 20,
		y_offset = 6,
		padding_right = 8,
	},
	background = { border_width = 0 },
	padding_left = 0,
	padding_right = 0,
	width = 0,
	drawing = false,
})

local media_title = sbar.add("item", "media.title", {
	position = "right",
	icon = { drawing = false },
	label = {
		string = "",
		font = { size = 11 },
		color = colors.white,
		max_chars = 18,
		y_offset = -5,
		padding_right = 8,
	},
	background = { border_width = 0 },
	padding_left = 0,
	padding_right = 0,
	width = 0,
	drawing = false,
})

local media_icon = sbar.add("item", "media.icon", {
	position = "right",
	icon = {
		string = icons.media.play_pause,
		font = { family = settings.nerd_font, size = 14.0 },
		color = colors.white,
		padding_left = 4,
		padding_right = 4,
	},
	label = { drawing = false },
	background = {
		color = colors.with_alpha(colors.black, 0.3),
		corner_radius = 6,
		height = 22,
		border_width = 0,
	},
	drawing = false,
	updates = true,
	update_freq = 3,
	popup = {
		align = "center",
		horizontal = true,
	},
})

-- Popup controls
sbar.add("item", {
	position = "popup." .. media_icon.name,
	icon = {
		string = icons.media.back,
		font = { family = settings.nerd_font, size = 16.0 },
		padding_left = 8,
		padding_right = 8,
	},
	label = { drawing = false },
	click_script = "media-control previous-track",
})

sbar.add("item", {
	position = "popup." .. media_icon.name,
	icon = {
		string = icons.media.play_pause,
		font = { family = settings.nerd_font, size = 18.0 },
		padding_left = 8,
		padding_right = 8,
	},
	label = { drawing = false },
	click_script = "media-control toggle-play-pause",
})

sbar.add("item", {
	position = "popup." .. media_icon.name,
	icon = {
		string = icons.media.forward,
		font = { family = settings.nerd_font, size = 16.0 },
		padding_left = 8,
		padding_right = 8,
	},
	label = { drawing = false },
	click_script = "media-control next-track",
})

-- Update media info
local function update_media()
	sbar.exec("media-control get 2>/dev/null", function(result)
		if type(result) == "table" then
			local title = result.title
			local artist = result.artist
			local playing = result.playing

			local has_media = title and title ~= ""

			if has_media then
				local icon = playing and icons.media.play_pause or icons.media.back

				media_icon:set({
					drawing = true,
					icon = { string = icon },
				})
				media_title:set({
					drawing = true,
					label = { string = title, width = "dynamic" },
				})
				media_artist:set({
					drawing = (artist and artist ~= ""),
					label = { string = artist or "", width = "dynamic" },
				})
			else
				media_icon:set({ drawing = false })
				media_title:set({ drawing = false })
				media_artist:set({ drawing = false })
			end
		else
			media_icon:set({ drawing = false })
			media_title:set({ drawing = false })
			media_artist:set({ drawing = false })
		end
	end)
end

-- Subscribe to events
media_icon:subscribe("routine", update_media)
media_icon:subscribe("forced", update_media)

media_icon:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "left" then
		sbar.exec("media-control toggle-play-pause")
		update_media()
	else
		media_icon:set({ popup = { drawing = "toggle" } })
	end
end)

media_icon:subscribe("mouse.exited.global", function()
	media_icon:set({ popup = { drawing = false } })
end)

-- Initial update
update_media()
