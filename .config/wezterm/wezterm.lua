local wezterm = require("wezterm")
local act = wezterm.action

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

local function resize_window_for_active_screen(window)
  local screen = wezterm.gui.screens().active

  local window_width = math.max(1, screen.width - (WINDOW_BUFFER * 2))
  local window_height = math.max(1, screen.height - (WINDOW_BUFFER * 2))

  window:set_inner_size(window_width, window_height)
  window:set_position(
    screen.x + WINDOW_BUFFER,
    screen.y + WINDOW_BUFFER - 19.5
  )
end

local function resize_when_gui_is_ready(mux_window, attempts_left)
  local gui_window = mux_window:gui_window()
  if gui_window then
    resize_window_for_active_screen(gui_window)
    return
  end

  if attempts_left > 0 then
    wezterm.time.call_after(0.1, function()
      resize_when_gui_is_ready(mux_window, attempts_left - 1)
    end)
  end
end

local function select_domain(window, pane)
  local choices = {}
  for _, domain in ipairs(wezterm.mux.all_domains()) do
    if domain:is_spawnable() then
      table.insert(choices, {
        label = domain:label(),
        id = domain:name(),
      })
    end
  end

  window:perform_action(
    act.InputSelector({
      title = "Select environment",
      choices = choices,
      action = wezterm.action_callback(function(_, _, id)
        if not id then
          return
        end

        local _, _, mux_window = wezterm.mux.spawn_window({
          domain = { DomainName = id },
        })
        resize_when_gui_is_ready(mux_window, 20)
      end),
    }),
    pane
  )
end

config.keys = {
  {
    key = "D",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      select_domain(window, pane)
    end),
  },
}

wezterm.on("gui-startup", function(cmd)
  local spawn_args = cmd or {}
  local _, _, mux_window = wezterm.mux.spawn_window(spawn_args)
  local window = mux_window:gui_window()

  resize_window_for_active_screen(window)
end)

return config
