local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Simple media widget using media-control (same info as macOS Control Center)

local artwork_dir = "/tmp"
local artwork_prefix = "sketchybar_album_art_"
local PROGRESS_BAR_WIDTH = 50

-- Seed random number generator
math.randomseed(os.time())

-- Generate random hash for unique filenames
local function random_hash()
	local chars = "abcdefghijklmnopqrstuvwxyz0123456789"
	local hash = ""
	for _ = 1, 8 do
		local idx = math.random(1, #chars)
		hash = hash .. chars:sub(idx, idx)
	end
	return hash
end

-- Album art item (rightmost, so it appears first visually)
local media_artwork = sbar.add("item", "media.artwork", {
	position = "right",
	icon = { drawing = false },
	label = { drawing = false },
	background = {
		drawing = true,
		color = 0x00000000,
		image = {
			scale = 0.4,
			corner_radius = 4,
		},
	},
	width = 25,
	padding_left = 4,
	padding_right = 4,
	drawing = false,
})

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

-- Progress bar disabled to save energy
-- local media_progress = sbar.add("slider", "media.progress", PROGRESS_BAR_WIDTH, {
-- 	position = "right",
-- 	slider = {
-- 		width = PROGRESS_BAR_WIDTH,
-- 		highlight_color = colors.with_alpha(colors.white, 0.6),
-- 		percentage = 0,
-- 		background = {
-- 			color = colors.with_alpha(colors.white, 0.15),
-- 			corner_radius = 0,
-- 			height = 2,
-- 		},
-- 	},
-- 	padding_left = 0,
-- 	padding_right = 8,
-- 	y_offset = -12,
-- 	drawing = false,
-- 	updates = true,
-- 	update_freq = 1,
-- })

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
	update_freq = 10,  -- Reduced from 3s to save energy
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

-- Track last artwork to avoid unnecessary updates
local last_artwork_hash = ""

-- Track playback state for progress calculation
local last_title = ""
local last_timestamp = 0
local last_elapsed = 0
local last_playing = false
local last_duration = 0

-- Parse ISO 8601 timestamp to Unix time
local function parse_timestamp(ts)
	if not ts then return 0 end
	local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"
	local year, month, day, hour, min, sec = ts:match(pattern)
	if year then
		return os.time({
			year = tonumber(year),
			month = tonumber(month),
			day = tonumber(day),
			hour = tonumber(hour),
			min = tonumber(min),
			sec = tonumber(sec),
		})
	end
	return 0
end

-- Progress bar disabled to save energy
-- local function update_progress_only()
-- 	if not last_playing or last_duration <= 0 then
-- 		return
-- 	end
--
-- 	local current_time = os.time(os.date("!*t"))
-- 	local elapsed = last_elapsed
-- 	if last_timestamp > 0 then
-- 		elapsed = last_elapsed + (current_time - last_timestamp)
-- 	end
--
-- 	-- Clamp elapsed to duration
-- 	if elapsed > last_duration then
-- 		elapsed = last_duration
-- 	end
-- 	if elapsed < 0 then
-- 		elapsed = 0
-- 	end
--
-- 	local progress_pct = math.floor((elapsed / last_duration) * 100)
-- 	media_progress:set({
-- 		slider = { percentage = progress_pct },
-- 	})
-- end

-- Track last update time for paused state polling
local last_update_time = 0
local PAUSED_UPDATE_INTERVAL = 10 -- Only check every 10 seconds when paused

-- Update media info
local function update_media()
	-- If paused, only update occasionally to detect resume
	if not last_playing and last_title ~= "" then
		local now = os.time()
		if now - last_update_time < PAUSED_UPDATE_INTERVAL then
			return
		end
		last_update_time = now
	end

	sbar.exec("media-control get 2>/dev/null", function(result)
		if type(result) == "table" then
			local title = result.title
			local artist = result.artist
			local playing = result.playing
			local artwork_data = result.artworkData
			local duration = result.duration or 0
			local timestamp = result.timestamp
			local reported_elapsed = result.elapsedTime or 0

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

				-- Store state for lightweight progress updates
				local ts_time = parse_timestamp(timestamp)
				last_timestamp = ts_time
				last_elapsed = reported_elapsed
				last_playing = playing
				last_duration = duration
				last_title = title
				last_update_time = os.time()

				-- Calculate current elapsed time
				local current_time = os.time(os.date("!*t")) -- UTC time
				local elapsed = reported_elapsed

				if playing and ts_time > 0 then
					local time_since_ts = current_time - ts_time
					elapsed = reported_elapsed + time_since_ts
				end

				-- Clamp elapsed to duration
				if elapsed > duration then
					elapsed = duration
				end
				if elapsed < 0 then
					elapsed = 0
				end

				-- Progress bar disabled to save energy
				-- local progress_pct = 0
				-- if duration > 0 then
				-- 	progress_pct = math.floor((elapsed / duration) * 100)
				-- end
				-- media_progress:set({
				-- 	drawing = true,
				-- 	slider = { percentage = progress_pct },
				-- })

				-- Handle album artwork
				if artwork_data and artwork_data ~= "" then
					-- Use last 200 chars of artwork data to detect changes (headers are at the start)
					local artwork_hash = string.sub(artwork_data, -200)
					if artwork_hash ~= last_artwork_hash then
						last_artwork_hash = artwork_hash
						-- Generate new unique filename
						local new_artwork_path = artwork_dir .. "/" .. artwork_prefix .. random_hash() .. ".jpg"
						-- Clear image first (required to force sketchybar to reload)
						sbar.exec("sketchybar --set media.artwork background.image=")
						-- Remove old files, decode new artwork, and crop to square
						sbar.exec(
							"rm -f "
								.. artwork_dir
								.. "/"
								.. artwork_prefix
								.. "*.jpg 2>/dev/null; media-control get 2>/dev/null | jq -r '.artworkData // empty' | base64 -d > "
								.. new_artwork_path
								.. " && sips -c 60 60 "
								.. new_artwork_path
								.. " --out "
								.. new_artwork_path
								.. " >/dev/null 2>&1",
							function()
								-- Set new image after file is written
								sbar.exec(
									"sketchybar --set media.artwork drawing=on background.image=" .. new_artwork_path
								)
							end
						)
					else
						media_artwork:set({ drawing = true })
					end
				else
					media_artwork:set({ drawing = false })
					last_artwork_hash = ""
				end
		else
			media_icon:set({ drawing = false })
			media_title:set({ drawing = false })
			media_artist:set({ drawing = false })
			media_artwork:set({ drawing = false })
			last_artwork_hash = ""
			last_playing = false
			last_duration = 0
		end
	else
		media_icon:set({ drawing = false })
		media_title:set({ drawing = false })
		media_artist:set({ drawing = false })
		media_artwork:set({ drawing = false })
		last_artwork_hash = ""
		last_playing = false
		last_duration = 0
	end
	end)
end

-- Subscribe to events
-- media_icon updates full state every 10 seconds
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
