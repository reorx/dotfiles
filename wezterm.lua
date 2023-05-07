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
config.font_size = 16
config.font = wezterm.font 'mononoki Nerd Font Mono'
config.window_background_opacity = 0.85
config.window_decorations = 'RESIZE'

local tab_bar_theme = {
  bg = '#888',
  active_bg = '#000',
  active_fg = '#fafafa',
  inactive_bg = '#666',
  inactive_fg =  '#ddd',
}

--config.use_fancy_tab_bar = false
config.window_frame = {
  -- The font used in the tab bar.
  -- Roboto Bold is the default; this font is bundled
  -- with wezterm.
  -- Whatever font is selected here, it will have the
  -- main font setting appended to it to pick up any
  -- fallback fonts you may have used there.
  font = wezterm.font { family = 'Hack', weight = 'Bold' },

  -- The size of the font in the tab bar.
  -- Default to 10. on Windows but 12.0 on other systems
  font_size = 12.0,

  -- The overall background color of the tab bar when
  -- the window is focused or not
  active_titlebar_bg = tab_bar_theme.bg,
  inactive_titlebar_bg = tab_bar_theme.bg,
}

config.colors = {
  tab_bar = {
    active_tab = {
      bg_color = tab_bar_theme.active_bg,
      fg_color = tab_bar_theme.active_fg,
    },
    inactive_tab = {
      bg_color = tab_bar_theme.inactive_bg,
      fg_color = tab_bar_theme.inactive_fg,
    },
    -- The color of the inactive tab bar edge/divider
    inactive_tab_edge = tab_bar_theme.bg,
  },
}

-- workspace
wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace() .. '  ')
end)


-- https://wezfurlong.org/wezterm/config/default-keys.html
-- https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html#available-key-assignments
-- wezterm show-keys --lua
config.keys = {
  -- pane
  { key = 'd', mods = 'SUPER', action = act.SplitHorizontal },
  { key = 'd', mods = 'SUPER|SHIFT', action = act.SplitVertical },
  { key = ']', mods = 'SUPER', action = act.ActivatePaneDirection 'Next' },
  { key = '[', mods = 'SUPER', action = act.ActivatePaneDirection 'Prev' },
  { key = ']', mods = 'CTRL|SHIFT', action = act.RotatePanes 'Clockwise' },
  { key = '[', mods = 'CTRL|SHIFT', action = act.RotatePanes 'CounterClockwise' },
  { key = 'o', mods = 'SUPER', action = act.PaneSelect },

  -- launcher
  { key = 'p', mods = 'SUPER|SHIFT', action = act.ActivateCommandPalette },
  { key = 'p', mods = 'SUPER', action = act.ShowTabNavigator },

  -- workspace
  -- Prompt for a name to use for a new workspace and switch to it.
  {
    key = 'W',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },

  -- from: https://github.com/wez/wezterm/issues/253
  -- use copy mode (CTRL SHIFT X) is better
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  {key="LeftArrow", mods="OPT", action=act{SendString="\x1bb"}},
  -- Make Option-Right equivalent to Alt-f; forward-word
  {key="RightArrow", mods="OPT", action=act{SendString="\x1bf"}},

  -- tab
  { key = '9', mods = 'SUPER', action = act.ActivateTab(-1) },
}


for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'SUPER',
    action = act.ActivateTab(i - 1),
  })
end


local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)


return config
