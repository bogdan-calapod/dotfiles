local wezterm = require 'wezterm'
local config = {}

config.color_scheme = 'tokyonight'

-- Font
config.font = wezterm.font { family = 'JetBrainsMono Nerd Font' }
config.font_size = 8.0
-- config.font_rules = {
--   {
--     intensity = 'Bold',
--     italic = true,
--     font = wezterm.font {
--       family = 'MonaspiceRn Nerd Font',
--       weight = 'Bold',
--       style = 'Italic',
--     },
--   },
--   {
--     italic = true,
--     intensity = 'Half',
--     font = wezterm.font {
--       family = 'MonaspiceRn Nerd Font',
--       weight = 'Regular',
--       style = 'Italic',
--     },
--   },
--   {
--     italic = true,
--     intensity = 'Normal',
--     font = wezterm.font {
--       family = 'MonaspiceRn Nerd Font',
--       style = 'Italic',
--     },
--   },
-- }

-- Window appearance
config.window_padding = { left = 0, right = 0, top = 4, bottom = 0 }
config.window_decorations = "RESIZE"

-- Misc config
config.enable_tab_bar = false
config.automatically_reload_config = true
config.window_background_opacity = 1

-- Change transparency on focus
wezterm.on("window-focus-changed", function(window)
  local config_overrides = window:get_config_overrides() or {}
  config_overrides.window_background_opacity = window:is_focused() and 0.95 or 1
  window:set_config_overrides(config_overrides)
end)

return config
