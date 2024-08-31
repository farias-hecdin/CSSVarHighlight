local M = {}

--- Rgb to Hex color ----------------------------------------------------------
local rgbToHex = function(r, g, b)
  local function toHex(num)
    return string.format("%02x", num)
  end
  return "#" .. toHex(r) .. toHex(g) .. toHex(b)
end

--- Lch to Hex color ----------------------------------------------------------
-- thanks to: https://stackoverflow.com/a/75850608/22265190
local function adjustColor(color)
  if color > 0.0031308 then
    return 1.055 * color^0.416666667 - 0.055
  else
    return 12.92 * color
  end
end

local lchToHex = function(l, c, h)
  local a = math.floor(c * math.cos(math.rad(h)) + 0.5)
  local b = math.floor(c * math.sin(math.rad(h)) + 0.5)

  local xw, yw, zw = 0.948110, 1.00000, 1.07304

  local fy = (l + 16) * 0.008620689655172414
  local fx = fy + (a * 0.002)
  local fz = fy - (b * 0.005)

  local fx3 = fx * fx * fx
  local fy3 = fy * fy * fy
  local fz3 = fz * fz * fz

  local x = xw * ((fx3 > 0.008856) and fx3 or ((fx - 0.137931034482759) * 0.128418549))
  local y = yw * ((fy3 > 0.008856) and fy3 or ((fy - 0.137931034482759) * 0.128418549))
  local z = zw * ((fz3 > 0.008856) and fz3 or ((fz - 0.137931034482759) * 0.128418549))

  local R = x * 3.2406 - y * 1.5372 - z * 0.4986
  local G = -x * 0.9689 + y * 1.8758 + z * 0.0415
  local B = x * 0.0557 - y * 0.2040 + z * 1.0570

  R = adjustColor(R)
  G = adjustColor(G)
  B = adjustColor(B)

  R = math.floor(math.max(math.min(R, 1), 0) * 255 + 0.5)
  G = math.floor(math.max(math.min(G, 1), 0) * 255 + 0.5)
  B = math.floor(math.max(math.min(B, 1), 0) * 255 + 0.5)

  return string.format("#%02x%02x%02x", R, G, B)
end

--- Hsl to Hex color ----------------------------------------------------------
-- thanks to: https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
local function hue2rgb(p, q, t)
  t = (t < 0) and t + 1 or (t > 1) and t - 1 or t
  if t < 0.16666667 then return p + (q - p) * 6 * t end
  if t < 0.5 then return q end
  if t < 0.66666667 then return p + (q - p) * (0.66666667 - t) * 6 end
  return p
end

local function hslToRgb(h, s, l)
  if s == 0 then return l, l, l end
  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q
  return hue2rgb(p, q, h + 0.33333333), hue2rgb(p, q, h), hue2rgb(p, q, h - 0.33333333)
end

local hslToHex = function(h, s, l)
  local r, g, b = hslToRgb(h * 0.002777778, s * 0.01, l * 0.01)
  return string.format("#%02x%02x%02x", r * 255, g * 255, b * 255)
end

--- Converts color values in various formats to hex color ---------------------
M.convert_color = function(data)
  local colors = {}

  for name, value in pairs(data) do
    if string.match(value, "%#%w%w%w%w%w%w") then
      colors[name] = value
    elseif string.match(value, "lch%(.+%)") then
      local x, y, z = string.match(value, "lch%((%d+%.?%d+)%p? (%d+%.?%d+) (%d+%.?%d+)%)")
      colors[name] = lchToHex(x, y, z)
    elseif string.match(value, "hsl%(.+%)") then
      local x, y, z = string.match(value, "hsl%((%d+)%a*, (%d+)%p?, (%d+)%p?%)")
      colors[name] = hslToHex(x, y, z)
    elseif string.match(value, "rgb%(.+%)") then
      local x, y, z = string.match(value, "rgb%((%d+), (%d+), (%d+)%)")
      colors[name] = rgbToHex(x, y, z)
    end
  end
  return colors
end

return M
