local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

-- Unicode circled capital letters start at U+24B6 (Ⓐ = A)
-- Unicode circled numbers: ① = U+2460 (1-9), ⓪ = U+24EA (0)
local function get_circled_char(char)
	local upper = char:upper()
	local byte = string.byte(upper)
	
	-- Handle A-Z
	if byte >= string.byte("A") and byte <= string.byte("Z") then
		return utf8.char(0x24B6 + (byte - string.byte("A")))
	end
	
	-- Handle 0-9
	if byte >= string.byte("0") and byte <= string.byte("9") then
		if char == "0" then
			return utf8.char(0x24EA) -- ⓪
		else
			return utf8.char(0x2460 + (byte - string.byte("1"))) -- ①-⑨
		end
	end
	
	-- Fallback: return a generic app icon
	return "●"
end

-- Helper function to get icon for an app, falling back to first letter if not defined
local function get_app_icon(app_name)
	local lookup = app_icons[app_name]
	if lookup ~= nil then
		return lookup
	end
	-- Return circled first letter of app name as fallback (e.g., Ⓢ for Slack)
	local first_char = app_name:sub(1, 1)
	return get_circled_char(first_char)
end

local workspaces = get_workspaces()
local current_workspace = get_current_workspace()
local function split(str, sep)
	local result = {}
	local regex = ("([^%s]+)"):format(sep)
	for each in str:gmatch(regex) do
		table.insert(result, each)
	end
	return result
end

-- Helper function to update icons for a single workspace
local function update_workspace_icons(workspace_index)
	sbar.exec("aerospace list-windows --workspace " .. workspace_index .. " --format '%{app-name}' --json ", function(apps)
		local icon_line = ""
		local no_app = true
		for _, app in ipairs(apps) do
			no_app = false
			local app_name = app["app-name"]
			local icon = get_app_icon(app_name)
			icon_line = icon_line .. " " .. icon
		end

		if no_app then
			icon_line = " "
		end

		sbar.animate("tanh", 10, function()
			spaces[workspace_index]:set({
				label = icon_line,
			})
		end)
	end)
end

-- Update all workspace icons
local function update_all_workspace_icons()
	for i, _ in ipairs(workspaces) do
		update_workspace_icons(i)
	end
end

for i, workspace in ipairs(workspaces) do
	local selected = workspace == current_workspace
	local space = sbar.add("item", "item." .. i, {
		icon = {
			font = {
				family = settings.font.numbers,
				size = 9.0,
			},
			string = i,
			padding_left = settings.items.padding.left,
			padding_right = settings.items.padding.left,
			color = settings.items.default_color(i),
			highlight_color = settings.items.highlight_color(i),
			highlight = selected,
		},
		label = {
			padding_left = 8,
			padding_right = 15,
			color = settings.items.default_color(i),
			highlight_color = settings.items.highlight_color(i),
			font = { family = settings.nerd_font, size = 14.0 },
			y_offset = 0,
			highlight = selected,
		},
		padding_right = 1,
		padding_left = 1,
		background = {
			color = settings.items.colors.background,
			border_width = 0,
			height = settings.items.height,
			border_color = selected and settings.items.highlight_color(i) or settings.items.default_color(i),
		},
		popup = {
			background = {
				border_width = 5,
				border_color = colors.black,
			},
		},
	})

	spaces[i] = space

	-- Define the icons for open apps on each space initially
	sbar.exec("aerospace list-windows --workspace " .. i .. " --format '%{app-name}' --json ", function(apps)
		local icon_line = ""
		local no_app = true
		for i, app in ipairs(apps) do
			no_app = false
			local app_name = app["app-name"]
			local icon = get_app_icon(app_name)
			icon_line = icon_line .. "  " .. icon
		end

		if no_app then
			icon_line = " "
		end

		sbar.animate("tanh", 10, function()
			space:set({
				label = icon_line,
			})
		end)
	end)

	-- Padding space between each item
	sbar.add("item", "item." .. i .. "padding", {
		script = "",
		width = settings.items.gap,
	})

	-- Item popup
	local space_popup = sbar.add("item", {
		position = "popup." .. space.name,
		padding_left = 5,
		background = {
			drawing = true,
			image = {
				corner_radius = 9,
				scale = 0.2,
			},
		},
	})

	space:subscribe("aerospace_workspace_change", function(env)
		-- Compare workspace index (i) with focused workspace
		-- env.FOCUSED_WORKSPACE comes as string from shell trigger
		local focused_ws = tonumber(env.FOCUSED_WORKSPACE)
		local prev_ws = tonumber(env.PREV_WORKSPACE)
		local selecteds = focused_ws == i
		space:set({
			icon = {
				highlight = selecteds,
				padding_right = 5,
			},
			label = {
				highlight = selecteds,
			},
			background = {
				border_color = selecteds and settings.items.highlight_color(i) or settings.items.default_color(i),
			},
		})

		-- Update window icons for focused and previous workspaces
		if focused_ws == i then
			update_workspace_icons(i)
		end
		if prev_ws == i and prev_ws ~= focused_ws then
			update_workspace_icons(i)
		end
	end)

	space:subscribe("mouse.clicked", function(env)
		local SID = split(env.NAME, ".")[2]
		if env.BUTTON == "other" then
			space_popup:set({
				background = {
					image = "item." .. SID,
				},
			})
			space:set({
				popup = {
					drawing = "toggle",
				},
			})
		else
			sbar.exec("aerospace workspace " .. SID)
		end
	end)

	space:subscribe("mouse.exited", function(_)
		space:set({
			popup = {
				drawing = false,
			},
		})
	end)
end

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

-- Handles the small icon indicator for spaces / menus changes
local spaces_indicator = sbar.add("item", {
	padding_left = 0,
	padding_right = 0,
	icon = {
		padding_left = 0,
		padding_right = 0,
		color = colors.red,
		string = icons.switch.on,
	},
	label = {
		width = 0,
		padding_left = 0,
		padding_right = 8,
		string = "Spaces",
		color = colors.bg1,
	},
	background = {
		color = colors.with_alpha(colors.grey, 0.0),
		border_color = colors.with_alpha(colors.bg1, 0.0),
	},
})

-- front_app_switched is a built-in sketchybar event that fires when any app gains/loses
-- focus, which covers window open, close, and focus changes. Update all workspaces to
-- catch windows appearing or disappearing on any space.
space_window_observer:subscribe("front_app_switched", function(env)
	update_all_workspace_icons()
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
	local currently_on = spaces_indicator:query().icon.value == icons.switch.on
	spaces_indicator:set({
		icon = currently_on and icons.switch.off or icons.switch.on,
	})
end)

spaces_indicator:subscribe("mouse.entered", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = {
					alpha = 1.0,
				},
				border_color = {
					alpha = 1.0,
				},
			},
			icon = {
				color = colors.bg1,
			},
			label = {
				width = "dynamic",
			},
		})
	end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
	sbar.animate("tanh", 30, function()
		spaces_indicator:set({
			background = {
				color = {
					alpha = 0.0,
				},
				border_color = {
					alpha = 0.0,
				},
			},
			icon = {
				color = colors.grey,
			},
			label = {
				width = 0,
			},
		})
	end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
	sbar.trigger("swap_menus_and_spaces")
end)
