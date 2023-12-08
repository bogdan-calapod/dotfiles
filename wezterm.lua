local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'tokyonight'

-- Font
config.font = wezterm.font('CaskaydiaCove Nerd Font', { weight = "DemiBold" })
config.font_size = 8.0

-- Window appearance
config.window_decorations = "RESIZE"
-- config.window_background_opacity = 0.95

-- Change transparency on focus
wezterm.on("window-focus-changed", function(window)
  local config_overrides = window:get_config_overrides() or {}
  config_overrides.window_background_opacity = window:is_focused() and 0.95 or 1
  window:set_config_overrides(config_overrides)
end)

-- Misc config
config.enable_tab_bar = false
config.automatically_reload_config = true

return config
