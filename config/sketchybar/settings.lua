local colors = require("colors")
local icons = require("icons")

-- Dynamic configuration based on monitor setup and display type
local function get_monitor_info()
	-- Get all monitors with their IDs and names
	local handle = io.popen("aerospace list-monitors 2>/dev/null")
	local monitors_str = handle:read("*a")
	handle:close()

	local monitors = {}
	local built_in_id = nil

	for line in monitors_str:gmatch("[^\r\n]+") do
		local id, name = line:match("(%d+)%s*|%s*(.+)")
		if id and name then
			monitors[tonumber(id)] = name
			if name:match("Built%-in") then
				built_in_id = tonumber(id)
			end
		end
	end

	-- Count monitors properly
	local count = 0
	for _ in pairs(monitors) do
		count = count + 1
	end

	return {
		monitors = monitors,
		built_in_id = built_in_id,
		monitor_count = count > 0 and count or 1,
	}
end

-- Get bar configuration for specific display
local function get_bar_config_for_display(display_id)
	local monitor_info = get_monitor_info()
	local is_built_in = display_id == monitor_info.built_in_id

	return {
		-- Built-in Display gets extra height due to notch, others get standard height
		height = is_built_in and 38 or 30,
		-- Built-in Display gets more padding due to notch considerations
		padding_x = is_built_in and 14 or 10,
		-- Item height adjusts proportionally
		item_height = is_built_in and 22 or 18,
	}
end

-- Default configuration - optimized for external monitors with notch handling built-in
local default_config = {
	height = 30, -- Standard height (notch_display_height handles Built-in Display)
	padding_x = 10, -- Standard padding
	item_height = 18, -- Standard item height
}

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
	-- Expose monitor info and config functions for other modules
	get_monitor_info = get_monitor_info,
	get_bar_config_for_display = get_bar_config_for_display,

	bar = {
		height = default_config.height,
		padding = {
			x = default_config.padding_x,
			y = 0,
		},
		background = colors.with_alpha(colors.black, 0.5),
	},
	items = {
		height = default_config.item_height,
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
