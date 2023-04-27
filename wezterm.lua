-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

local act = wezterm.action

--config.color_scheme = 'Batman'
config.color_scheme = "Tomorrow Night Bright"
config.font_size = 14

config.keys = {
  { key = 'd', mods = 'CMD', action = act.SplitHorizontal },
  { key = 'd', mods = 'CMD|SHIFT', action = act.SplitVertical },
  { key = ']', mods = 'CMD', action = act.ActivatePaneDirection 'Next' },
  { key = '[', mods = 'CMD', action = act.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CTRL|SHIFT', action = act.RotatePanes 'Clockwise' },
  { key = '[', mods = 'CTRL|SHIFT', action = act.RotatePanes 'CounterClockwise' },
  { key = '9', mods = 'CMD', action = act.ActivateTab(-1) },

}

for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'CMD',
    action = act.ActivateTab(i - 1),
  })
end

return config
