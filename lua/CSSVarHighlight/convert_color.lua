local M = {}

--- Rgb to Hex color
M.rgbToHex = function(r, g, b)
  local function toHex(num)
    return string.format("%02x", num)
  end
  return "#" .. toHex(r) .. toHex(g) .. toHex(b)
end

--- Lch to Hex color
function M.lchToHex(l, c, h)
  local radH = math.rad(h)
  local a = math.floor(c * math.cos(radH) + 0.5)
  local b = math.floor(c * math.sin(radH) + 0.5)

  local xw, yw, zw = 0.948110, 1.00000, 1.07304

  local fy = (l + 16) * 0.0086206897
  local fx = fy + (a * 0.002)
  local fz = fy - (b * 0.002)

  local x = xw * ((fx ^ 3 > 0.008856) and fx ^ 3 or ((fx - 0.137931034) * 0.1284))
  local y = yw * ((fy ^ 3 > 0.008856) and fy ^ 3 or ((fy - 0.137931034) * 0.1284))
  local z = zw * ((fz ^ 3 > 0.008856) and fz ^ 3 or ((fz - 0.137931034) * 0.1284))

  local R = x * 3.2406 - y * 1.5372 - z * 0.4986
  local G = -x * 0.9689 + y * 1.8758 + z * 0.0415
  local B = x * 0.0557 - y * 0.2040 + z * 1.0570

  R = R > 0.0031308 and 1.055 * R ^ (0.416666667) - 0.055 or 12.92 * R
  G = G > 0.0031308 and 1.055 * G ^ (0.416666667) - 0.055 or 12.92 * G
  B = B > 0.0031308 and 1.055 * B ^ (0.416666667) - 0.055 or 12.92 * B

  R = math.floor(math.max(math.min(R, 1), 0) * 255 + 0.5)
  G = math.floor(math.max(math.min(G, 1), 0) * 255 + 0.5)
  B = math.floor(math.max(math.min(B, 1), 0) * 255 + 0.5)

  return string.format("#%02x%02x%02x", R, G, B)
end

--- Hsl to Hex color
function M.hslToHex(H, S, L)
  local function hueToRgb(p, q, t)
    if t < 0 then
      t = t + 1
    elseif t > 1 then
      t = t - 1
    elseif t < 0.1666666667 then
      return p + (q - p) * 6 * t
    elseif t < 0.5 then
      return q
    elseif t < 0.6666666667 then
      return p + (q - p) * (0.6666666667 - t) * 6
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

      r = hueToRgb(p, q, h + 0.3333333333)
      g = hueToRgb(p, q, h)
      b = hueToRgb(p, q, h - 0.3333333333)
    end
    return r * 255, g * 255, b * 255
  end

  local r, g, b = hslToRgb(H * 0.0027777778, S * 0.01, L * 0.01)
  return string.format("#%02x%02x%02x", r, g, b)
end

return M
