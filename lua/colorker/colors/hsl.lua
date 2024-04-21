-- Thanks to: https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
local M = {}

local function hueToRgb(p, q, t)
  if t < 0 then
    t = t + 1
  end
  if t > 1 then
    t = t - 1
  end
  if t < 1 / 6 then
    return p + (q - p) * 6 * t
  end
  if t < 1 / 2 then
    return q
  end
  if t < 2 / 3 then
    return p + (q - p) * (2 / 3 - t) * 6
  end
  return p
end

local function hslToRgb(h, s, l)
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l
  else
    local q
    if l < 0.5 then
      q = l * (1 + s)
    else
      q = l + s - l * s
    end
    local p = 2 * l - q

    r = hueToRgb(p, q, h + 1 / 3)
    g = hueToRgb(p, q, h)
    b = hueToRgb(p, q, h - 1 / 3)
  end
  return r * 255, g * 255, b * 255
end

function M.hslToHex(h, s, l)
  local r, g, b = hslToRgb(h / 360, s / 100, l / 100)
  return string.format("#%02x%02x%02x", r, g, b)
end

return M
