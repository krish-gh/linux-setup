local wezterm = require 'wezterm'

local config = wezterm.config_builder()

--config.enable_wayland = false
config.default_prog = { "/bin/bash" }
config.color_scheme = 'Catppuccin Mocha'
config.font_size = 14.0
config.hide_tab_bar_if_only_one_tab = true
config.audible_bell = 'Disabled'

return config