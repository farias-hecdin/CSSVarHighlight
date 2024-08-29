local M = {}
local cfg = require('CSSVarHighlight.config')
local fos = require('CSSVarHighlight.file_ops')
local cvr = require('CSSVarHighlight.convert_color')
local gdt = require('CSSVarHighlight.get_data')

local g_colorsFromFile = {}
local g_lastFile, g_lastDir = nil, nil
local g_isPluginInitialized, g_showLog = false, true

M.setup = function(options)
  -- Merge the user-provided options with the default options
  cfg.options = vim.tbl_deep_extend("keep", options or {}, cfg.options)
  -- Enable keymap if they are not disableds
  if not cfg.options.disable_keymaps then
    local keymaps_opts = {buffer = 0, silent = true}
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'CSSVarHighlight keymaps',
      pattern = 'css',
      callback = function()
        vim.keymap.set('n', '<leader>ch', ":CSSVarHighlight<CR>", keymaps_opts)
      end,
    })
  end
end

-- Analyze the arguments provided
local function parse_args(args)
  local attempt_limit = tonumber(cfg.options.parent_search_limit)
  local fname = g_lastFile or cfg.options.filename_to_track
  local fdir = g_lastDir or nil

  local num_args = #args.fargs

  if num_args > 0 then
    local arg1 = args.fargs[1]
    if tonumber(arg1) then
      attempt_limit = tonumber(arg1)
    else
      fname = arg1
    end
  end

  if num_args > 1 then
    local arg2 = args.fargs[2]
    if tonumber(arg2) then
      attempt_limit = tonumber(arg2)
    else
      fdir = arg2
    end
  end

  return attempt_limit, fname, fdir
end

--- Create a user command
vim.api.nvim_create_user_command("CSSVarHighlight", function(args)
  local attempt_limit, fname, fdir = parse_args(args)
  g_lastFile, g_lastDir = fname, fdir
  if g_loadLastFile ~= fname then
    g_showLog = true
  end

  M.get_colors_from_file(attempt_limit, fname .. ".css", fdir)

  -- Event to auto-reload the data
  if g_isPluginInitialized then
    vim.api.nvim_create_autocmd({"BufWritePost"}, {
      pattern = "*.css",
      callback = function()
        vim.cmd('CSSVarHighlight')
      end,
    })
  end

  g_isPluginInitialized = true
end, {desc = "Track the colors of the CSS variables", nargs = "*"})

--- Converts color values in various formats to hex color
local convert_color = function(data)
  local colors = {}

  for name, value in pairs(data) do
    if string.match(value, "%#%w%w%w%w%w%w") then
      colors[name] = value
    elseif string.match(value, "lch%(.+%)") then
      local x, y, z = string.match(value, "lch%((%d+%.?%d+)%p? (%d+%.?%d+) (%d+%.?%d+)%)")
      colors[name] = cvr.lchToHex(x, y, z)
    elseif string.match(value, "hsl%(.+%)") then
      local x, y, z = string.match(value, "hsl%((%d+)%a*, (%d+)%p?, (%d+)%p?%)")
      colors[name] = cvr.hslToHex(x, y, z)
    elseif string.match(value, "rgb%(.+%)") then
      local x, y, z = string.match(value, "rgb%((%d+), (%d+), (%d+)%)")
      colors[name] = cvr.rgbToHex(x, y, z)
    end
  end
  return colors
end

--- Retrieves color values from a file and updates the mini.hipatterns plugin
M.get_colors_from_file = function(attempt_limit, fname, fdir)
  -- Search for the file with the given parameters.
  local fpath = fos.find_file(fname, fdir, 1, attempt_limit)
  if not fpath then
    vim.print("[CSSVarHighlight] Attempt limit reached. Operation cancelled.")
    return
  end
  -- Extract colors from the found file.
  local data = gdt.get_css_attribute(fpath, cfg.options.variable_pattern)
  g_colorsFromFile = convert_color(data)
  -- Try to load the 'mini.hipatterns' plugin.
  local plugin_ok, plugin = pcall(require, "mini.hipatterns")
  if not plugin_ok then
    vim.print("[CSSVarHighlight] The 'mini.hipatterns' plugin was not found.")
    return
  end
  if plugin then
    vim.cmd('lua MiniHipatterns.update()')
    if g_showLog then
      vim.print("[CSSVarHighlight] The data has been updated. " .. os.date("%H:%M:%S"))
      g_showLog = false
    end
  end
end

--- Retrieves the settings for the mini.hipatterns plugin
M.get_settings = function()
  local plugin_ok, plugin = pcall(require, "mini.hipatterns")
  if not plugin_ok then
    vim.print("[CSSVarHighlight] The 'mini.hipatterns' plugin was not found.")
    return
  end

  local data = {
    pattern = "var%(" .. cfg.options.variable_pattern .. "%)",
    group = function (_, match)
      local match_value = match:match("var%((.+)%)")
      local color = g_colorsFromFile[match_value] or cfg.options.initial_variable_color
      if g_isPluginInitialized then
        return plugin.compute_hex_color_group(color, "bg")
      end
      return nil
    end
  }
  return data
end

return M
