local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'tokyonight'

-- Font
config.font = wezterm.font('CaskaydiaCove Nerd Font', { weight = "DemiBold" })
config.font_size = 8.0

-- Window appearance
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95

-- Misc config
config.enable_tab_bar = false


return config
