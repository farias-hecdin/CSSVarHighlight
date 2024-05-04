local M = {}
local vim = vim
local cfg = require('CSSVarHighlight.misc.config')
local lch = require('CSSVarHighlight.colors.lch')
local hsl = require('CSSVarHighlight.colors.hsl')
local rgb = require('CSSVarHighlight.colors.rgb')
local cph = require('CSSPluginHelpers')

local colors_from_file = {}

M.setup = function(options)
  -- Merge the user-provided options with the default options
  cfg.options = vim.tbl_deep_extend("keep", options or {}, cfg.options)
  -- Enable keymap if they are not disableds
  if not cfg.options.disable_keymaps then
    local keymaps_opts = {buffer = 0, silent = true}
    -- Create the keymaps for the specified filetypes
    vim.api.nvim_create_autocmd('FileType', {
      desc = 'CSSVarHighlight keymaps',
      pattern = 'css',
      callback = function()
        vim.keymap.set('n', '<leader>ch', ":CSSVarHighlight<CR>", keymaps_opts)
      end,
    })
  end
end

--- Create a user command
vim.api.nvim_create_user_command("CSSVarHighlight", function(args)
  if #(args.fargs[1] or "") > 1 then
    args.fargs[1], args.fargs[2], args.fargs[3] = 1, args.fargs[1], args.fargs[2]
  end

  local attempt_limit = args.fargs[1] or cfg.options.parent_search_limit
  local fname = (args.fargs[2] or cfg.options.filename_to_track) .. ".css"
  local fdir = args.fargs[3] or nil

  M.get_colors_from_file(tonumber(attempt_limit), fname, fdir)
end, {desc = "Track the colors of the CSS variables", nargs = "*"})

--- Retrieves color values from a file and updates the mini.hipatterns plugin
M.get_colors_from_file = function(attempt_limit, fname, fdir)
  local fpath = cph.find_file(fname, fdir, 1, attempt_limit)
  if not fpath then
    vim.print("[CSSVarHighlight] Attempt limit reached. Operation cancelled.")
    return
  end

  local data = cph.get_css_attribute(fpath, cfg.options.variable_pattern)
  colors_from_file = M.convert_color(data)

  vim.cmd('lua MiniHipatterns.update()')
end

--- Converts color values in various formats to hex color
M.convert_color = function(data)
  local colors = {}

  for name, value in pairs(data) do
    if string.match(value, "%#%w%w%w%w%w%w") then
      colors[name] = value
    elseif string.match(value, "lch%(.+%)") then
      local x, y, z = string.match(value, "lch%((%d+%.?%d+)%p? (%d+%.?%d+) (%d+%.?%d+)%)")
      colors[name] = lch.lchToHex(x, y, z)
    elseif string.match(value, "hsl%(.+%)") then
      local x, y, z = string.match(value, "hsl%((%d+)%a*, (%d+)%p?, (%d+)%p?%)")
      colors[name] = hsl.hslToHex(x, y, z)
    elseif string.match(value, "rgb%(.+%)") then
      local x, y, z = string.match(value, "rgb%((%d+), (%d+), (%d+)%)")
      colors[name] = rgb.rgbToHex(x, y, z)
    end
  end

  return colors
end

--- Retrieves the settings for the mini.hipatterns plugin
M.get_settings = function()
  local plugin = require('mini.hipatterns')

  local data = {
    pattern = "var%(" .. cfg.options.variable_pattern .. "%)",
    group = function (_, match)
      local match_value = match:match("var%((.+)%)")
      local color = colors_from_file[match_value] or cfg.options.initial_variable_color
      return plugin.compute_hex_color_group(color, "bg")
    end
  }

  return data
end

return M