local M = {}
local vim = vim
local config = require('colorker.misc.config')
local operations = require('colorker.misc.file_operations')
local lch = require('colorker.colors.lch')
local hsl = require('colorker.colors.hsl')
local rgb = require('colorker.colors.rgb')

local plugin_exists, plugin = pcall(require, "mini.hipatterns")
local color_from_css_file = {}

M.setup = function(options)
  -- Merge the user-provided options with the default options
  config.options = vim.tbl_deep_extend("keep", options or {}, config.options)
  -- Enable keymap if they are not disableds
  if not config.options.disable_keymaps then
    local keymaps_opts = {buffer = 0, silent = true}
    local filetypes = 'css'
    -- Create the keymaps for the specified filetypes
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'colorker.nvim keymaps',
      pattern = filetypes,
      callback = function()
        vim.keymap.set('v', '<leader>cx', "Colorker<CR>", keymaps_opts)
      end,
    })
  end
end

-- Crear un commando para la funcionalidad
vim.api.nvim_create_user_command("Colorker", function(args)
  local filename = args.fargs[1] or config.options.filename_to_track
  local attempt_limit = tonumber(args.fargs[1] or config.options.parent_search_limit)

  M.get_color_from_css_file(filename, attempt_limit)
end, {desc = "Track the colors of the CSS variables", nargs = "*"})

M.get_color_from_css_file = function(filename, attempt_limit)
  filename = filename .. ".css"

  local color_variable_pattern = config.options.color_variable_pattern
  local color_patterns = {
    hex = '%#%w%w%w%w%w%w',
    lch = 'lch%(.+%)',
    hsl = 'hsl%(.+%)',
    rgb = 'rgb%(.+%)',
  }

  local css_file_path = operations.find_file(filename, nil, 1, attempt_limit)
  if not css_file_path then
    return
  end

  local data = operations.open_file(css_file_path, color_variable_pattern, color_patterns)
  if not data then
    return
  end

  color_from_css_file = M.convert_color(data)

  if not plugin_exists then
    return
  end
  vim.cmd('lua MiniHipatterns.update()')
end

M.convert_color = function(data)
  local color_from_file = {}

  for variable_name, color_value in pairs(data) do
    if string.match(color_value, "#") then
      color_from_file[variable_name] = color_value
    elseif string.match(color_value, "lch%(") then
      local x, y, z = string.match(color_value, "lch%((%d+%.?%d+)%p? (%d+%.?%d+) (%d+%.?%d+)%)")
      color_from_file[variable_name] = lch.lchToHex(x, y, z)
    elseif string.match(color_value, "hsl%(") then
      local x, y, z = string.match(color_value, "hsl%((%d+)%a*, (%d+)%p?, (%d+)%p?%)")
      color_from_file[variable_name] = hsl.hslToHex(x, y, z)
    elseif string.match(color_value, "rgb%(") then
      local x, y, z = string.match(color_value, "rgb%((%d+), (%d+), (%d+)%)")
      color_from_file[variable_name] = rgb.rgbToHex(x, y, z)
    end
  end

  return color_from_file
end


M.get_settings = function()
  if not plugin_exists then
    return
  end

  local data = {
    pattern = "var%(%-%-[-_%w]+color[-%w]*%)",
    group = function (_, match)
      local match_value = match:match("var%((.+)%)")
      local color = color_from_css_file[match_value] or "#000000"
      return plugin.compute_hex_color_group(color, "bg")
    end
  }

  return data
end

return M
