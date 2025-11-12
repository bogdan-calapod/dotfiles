local settings = require("settings")

-- Single bar configuration that appears on all displays
-- Uses SketchyBar's built-in notch_display_height for different heights per display type
sbar.bar({
	topmost = "window",
	height = 30, -- Standard height for external monitors
	notch_display_height = 58, -- Larger height specifically for notched displays (Built-in)
	color = settings.bar.background,
	padding_right = settings.bar.padding.x,
	padding_left = settings.bar.padding.x,
	-- Notch-specific settings
	notch_offset = 2, -- Additional offset for notched screens
	notch_width = 200, -- Default notch width
	-- Show on all displays
	display = "all",
	sticky = true,
	position = "top",
	shadow = false,
	blur_radius = 5,
})
