local wezterm = require("wezterm")
local config = {}
local font = "MonaspiceAr Nerd Font Propo"
local italicFont = "MonaspiceRn Nerd Font Propo"

-- Theme
config.color_scheme = "tokyonight"

-- Font
config.font_rules = {
	{
		intensity = "Bold",
		italic = false,
		font = wezterm.font({ family = font, style = "Normal" }),
	},
	{
		intensity = "Normal",
		italic = false,
		font = wezterm.font({ family = font, style = "Normal" }),
	},
	{
		intensity = "Half",
		italic = false,
		font = wezterm.font({ family = font, style = "Normal" }),
	},
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({ family = italicFont, style = "Italic" }),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({ family = italicFont, style = "Italic" }),
	},
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font({ family = italicFont, style = "Italic" }),
	},
}
config.font_size = 12.0
config.line_height = 1.1
config.cell_width = 1.0
config.enable_kitty_graphics = true
config.freetype_load_flags = "NO_HINTING"

-- Window appearance
config.window_padding = { left = 0, right = 0, top = 4, bottom = 0 }
config.window_decorations = "RESIZE"
config.macos_window_background_blur = 20

-- Misc config
config.term = "xterm-256color"
config.enable_tab_bar = false
config.automatically_reload_config = true
config.window_background_opacity = 1

-- Maximize window on stars;t
wezterm.on("gui-startup", function()
	local tab, pane, window = wezterm.mux.spawn_window()
	window:gui_window():toggle_fullscreen()
end)

-- Change transparency on focus
wezterm.on("window-focus-changed", function(window)
	local config_overrides = window:get_config_overrides() or {}
	config_overrides.window_background_opacity = window:is_focused() and 0.90 or 1
	window:set_config_overrides(config_overrides)
end)

-- Quake
require("wuake").setup({
	config = config,
})

return config
