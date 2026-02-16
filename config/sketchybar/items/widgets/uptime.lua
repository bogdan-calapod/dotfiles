local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local uptime = sbar.add("item", "widgets.uptime", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
			size = 16.0,
		},
	},
	label = {
		font = {
			family = settings.font.numbers,
			size = 12.0,
		},
	},
	update_freq = 60,
})

uptime:subscribe({ "routine", "forced", "system_woke" }, function()
	sbar.exec("sysctl -n kern.boottime", function(result)
		-- Parse boot time from sysctl output
		-- Format: { sec = 1234567890, usec = 123456 } ...
		local boot_seconds = result:match("sec = (%d+)")
		
		if boot_seconds then
			local boot_time = tonumber(boot_seconds)
			local current_time = os.time()
			local uptime_seconds = current_time - boot_time
			
			-- Convert to days, hours, minutes
			local days = math.floor(uptime_seconds / 86400)
			local hours = math.floor((uptime_seconds % 86400) / 3600)
			local minutes = math.floor((uptime_seconds % 3600) / 60)
			
			-- Format display - compact, showing only largest unit
			local label = ""
			if days > 0 then
				label = days .. "d"
			elseif hours > 0 then
				label = hours .. "h"
			else
				label = minutes .. "m"
			end
			
			-- Determine color - orange if over 6 days, otherwise use default
			local color = colors.white
			if days > 6 then
				color = colors.orange
			end
			
			uptime:set({
				icon = {
					string = icons.uptime or "󰅐",
					color = color,
				},
				label = {
					string = label,
					color = color,
				},
			})
		end
	end)
end)

-- Add bracket for consistent styling with other widgets
sbar.add("bracket", "widgets.uptime.bracket", { uptime.name }, {
	background = {
		color = colors.transparent,
		border_color = colors.transparent,
		border_width = 1,
	},
})

-- Add padding after uptime widget
sbar.add("item", "widgets.uptime.padding", {
	position = "right",
	width = settings.group_paddings,
})