local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- config.color_scheme = "rose-pine-moon"
config.color_scheme = "Catch Me If You Can (terminal.sexy)"
-- config.color_scheme = "Ef-Trio-Dark"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 11.0
config.window_background_opacity = 0.90
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Window placement and sizing
local WINDOW_BUFFER = 150

wezterm.on("gui-startup", function(cmd)
  local screen = wezterm.gui.screens().active
  
  local window_width = math.max(1, screen.width - (WINDOW_BUFFER * 2))
  local window_height = math.max(1, screen.height - (WINDOW_BUFFER * 2))

  local spawn_args = cmd or {}
  local _, _, mux_window = wezterm.mux.spawn_window(spawn_args)
  local window = mux_window:gui_window()

  window:set_inner_size(window_width, window_height)
  window:set_position(
    screen.x + WINDOW_BUFFER,
    screen.y + WINDOW_BUFFER - 19.5
  )
end)

return config
