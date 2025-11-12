local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Create a single widget that displays both total count and app icons
local notifications = sbar.add("item", "widgets.notifications", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
		string = icons.notifications.none,
		color = colors.grey,
	},
	label = {
		font = {
			family = settings.font.numbers,
			size = 12.0,
		},
		string = "",
		color = colors.white,
	},
	update_freq = 30, -- Update every 30 seconds
})

-- Function to get app icon based on app name
local function get_app_icon(app_name)
	-- Try exact match first, then fallback to default
	return app_icons[app_name] or app_icons["default"] or ""
end

-- Function to update the notification display
local function update_notifications()
	sbar.exec("./helpers/notifications.sh", function(result)
		-- Parse the result: format is "total_count|app1:count1,app2:count2,..."
		local total_count = 0
		local apps_data = {}

		if result and result ~= "" then
			local parts = {}
			for part in string.gmatch(result, "[^|]+") do
				table.insert(parts, part)
			end

			total_count = tonumber(parts[1]) or 0

			if parts[2] then
				-- Parse app data
				for app_info in string.gmatch(parts[2], "[^,]+") do
					local app_parts = {}
					for part in string.gmatch(app_info, "[^:]+") do
						table.insert(app_parts, part)
					end
					if #app_parts == 2 then
						local app_name = app_parts[1]
						local app_count = tonumber(app_parts[2]) or 0
						table.insert(apps_data, { name = app_name, count = app_count })
					end
				end
			end
		end

		-- Build the display string
		local icon_string = icons.notifications.none
		local label_string = ""
		local icon_color = colors.grey

		if total_count > 0 then
			icon_color = colors.white

			-- Create a string with app icons and total count
			local app_icons = {}
			for _, app_data in ipairs(apps_data) do
				table.insert(app_icons, get_app_icon(app_data.name))
			end

			-- If we have specific apps, show their icons, otherwise show general badge
			if #app_icons > 0 then
				-- Show all app icons
				icon_string = table.concat(app_icons, " ")

				-- Show total count
				if total_count > 99 then
					label_string = "99+"
				else
					label_string = tostring(total_count)
				end
			else
				icon_string = icons.notifications.badge
				if total_count > 99 then
					label_string = "99+"
				else
					label_string = tostring(total_count)
				end
			end
		end

		notifications:set({
			icon = {
				string = icon_string,
				color = icon_color,
			},
			label = {
				string = label_string,
			},
		})
	end)
end

-- Subscribe to events
notifications:subscribe({ "routine", "system_woke", "forced" }, update_notifications)

-- Initial update
update_notifications()

-- Add bracket styling
sbar.add("bracket", "widgets.notifications.bracket", { notifications.name }, {
	background = {
		color = colors.transparent,
		border_color = colors.transparent,
		border_width = 1,
	},
})

-- Add padding
sbar.add("item", "widgets.notifications.padding", {
	position = "right",
	width = settings.group_paddings,
})

