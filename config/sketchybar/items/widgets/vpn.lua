local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local vpn = sbar.add("item", "widgets.vpn", {
	position = "right",
	icon = {
		string = icons.vpn.disconnected,
		color = colors.grey,
		font = {
			style = settings.font.style_map["Regular"],
			size = 14.0,
		},
	},
	label = {
		string = "",
		font = {
			family = settings.font.text,
			style = settings.font.style_map["Regular"],
			size = 13.0,
		},
	},
	update_freq = 120, -- Check VPN status every 2 minutes (VPN state changes rarely)
})

sbar.add("item", "widgets.vpn.padding", {
	position = "right",
	width = settings.group_paddings,
})

local function check_vpn_status()
	-- Use scutil to check for VPN connections
	sbar.exec("scutil --nc list | grep Connected | sed -E 's/.*\"([^\"]+)\".*/\\1/' | head -1", function(result)
		local vpn_name = result:gsub("^%s+", ""):gsub("%s+$", "")
		
		if vpn_name ~= "" then
			-- VPN is connected
			-- Truncate long VPN names
			local display_name = vpn_name
			if #display_name > 15 then
				display_name = display_name:sub(1, 12) .. "..."
			end
			
			vpn:set({
				icon = {
					string = icons.vpn.connected,
					color = colors.green,
				},
				label = {
					string = display_name:lower(),
					color = colors.green,
				},
			})
		else
			-- No VPN connected
			vpn:set({
				icon = {
					string = icons.vpn.disconnected,
					color = colors.grey,
				},
				label = {
					string = "",
				},
			})
		end
	end)
end

-- Initial check
check_vpn_status()

-- Subscribe to routine updates
vpn:subscribe("routine", check_vpn_status)
vpn:subscribe("forced", check_vpn_status)

-- Click to toggle details or refresh
vpn:subscribe("mouse.clicked", function(env)
	if env.BUTTON == "right" then
		-- Right click opens Network preferences
		sbar.exec("open /System/Library/PreferencePanes/Network.prefpane")
	else
		-- Left click refreshes status
		check_vpn_status()
	end
end)

return vpn