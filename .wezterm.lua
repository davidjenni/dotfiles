-- https://wezfurlong.org/wezterm/config/files.html
local wez = require 'wezterm'
local config = wez.config_builder()

config.color_scheme = 'tokyo'
config.initial_cols = 180
config.initial_rows = 60

config.font = wez.font('JetBrainsMono Nerd Font', { weight = 'Light' })
-- config.color_scheme = 'Tokyo Night'
config.window_background_opacity = 0.94

config.window_decorations = 'RESIZE'
config.use_fancy_tab_bar = false

-- fallback if not in gui terminal
local function get_appearance()
  if wez.gui then
    return wez.gui.get_appearance()
  end
  return 'Dark'
end

local function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    return 'Tokyo Night'
  else
    return 'Tokyo Night Day'
  end
end

config.color_scheme = scheme_for_appearance(get_appearance())

return config
