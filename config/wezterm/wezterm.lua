local wezterm = require("wezterm")
local config = {}
local font = "Maple Mono NF"

-- Theme
config.color_scheme = "tokyonight"

-- Font
config.font_rules = {
	{
		intensity = "Bold",
		italic = true,
		font = wezterm.font({ family = font, style = "Italic" }),
	},
	{
		intensity = "Normal",
		italic = true,
		font = wezterm.font({ family = font, style = "Italic" }),
	},
	{
		intensity = "Half",
		italic = true,
		font = wezterm.font({ family = font, style = "Italic" }),
	},
}
config.font_size = 12.0

-- Window appearance
config.window_padding = { left = 0, right = 0, top = 4, bottom = 0 }
config.window_decorations = "RESIZE"
config.macos_window_background_blur = 20

-- Keybinds
config.leader = { key = "h", mods = "CTRL", timeout_milliseconds = 5000 }
config.keys = {
	{
		key = "j",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "c",
		mods = "LEADER",
		action = wezterm.action.SpawnTab("DefaultDomain"),
	},
	{
		key = "x",
		mods = "LEADER",
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
}

-- Misc config
config.term = "wezterm"
config.enable_tab_bar = false
config.automatically_reload_config = true
config.window_background_opacity = 1

-- Maximize window on start
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
