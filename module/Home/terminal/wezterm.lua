local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- カラースキーム
config.color_scheme = "Dracula"

config.window_decorations = "RESIZE"
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- ■ フォント設定の修正 ■
-- サイズを少し大きくし、行の高さを1.0〜1.1に固定して「潰れ」を防ぎます
config.font = wezterm.font("HackGen35 Console NF")
config.font_size = 13.0 -- 10だとPowerline記号が潰れやすいので少し大きく
config.line_height = 1.1 -- 行間を少し空けてグリフの上下切れを防ぐ

-- ■ tabline.wez の設定修正 ■
local tabline = wezterm.plugin.require("https://github.com/michaelbrusegard/tabline.wez")
tabline.setup({
	options = {
		-- theme = "catppuccin-mocha",
		theme = "Tokyo Night",
		-- theme = "Cobalt Neon",
		section_separators = {
			left = wezterm.nerdfonts.ple_upper_left_triangle,
			right = wezterm.nerdfonts.ple_lower_right_triangle,
		},
		component_separators = {
			left = wezterm.nerdfonts.ple_forwardslash_separator,
			right = wezterm.nerdfonts.ple_forwardslash_separator,
		},
		tab_separators = {
			left = wezterm.nerdfonts.ple_upper_left_triangle,
			right = wezterm.nerdfonts.ple_lower_right_triangle,
		},
		-- color_overrides = {
		theme_overrides = {
			tab = {
				active = { fg = "#091833", bg = "#59c2c6" },
			},
		},
	},
	sections = {
		tab_active = {
			"index",
			{ "process", padding = { left = 0, right = 1 } },
			"",
			{ "cwd", padding = { left = 1, right = 0 } },
			{ "zoomed", padding = 1 },
		},
		tab_inactive = {
			"index",
			{ "process", padding = { left = 0, right = 1 } },
			"󰉋",
			{ "cwd", padding = { left = 1, right = 0 } },
			{ "zoomed", padding = 1 },
		},
		tabline_x = { "ram", "cpu" },
		tabline_y = {},
		tabline_z = { "domain" },
	},
})
config.default_cursor_style = "SteadyBlock"
config.colors = {
	cursor_fg = "#11111b",
	cursor_bg = "#59c2c6",
	cursor_border = "#59c2c6",
}

-- 背景透過の設定
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

local act = wezterm.action
config.key_tables = {
	resize_pane = {
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },

		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },

		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },

		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },

		-- Cancel the mode
		{ key = "Escape", action = "PopKeyTable" },
	},
}

return config
