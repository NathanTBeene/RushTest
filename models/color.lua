---@class Color : Class
Color = Class:extend("Color")

---* Note:
---* I don't prefer using the Love2D color format of 0-1 for each channel,
---* so this Color class takes the more commonly used 0-255 format and,
---* converts it to 0-1 for internal storage and use with Love2D.

--- Constructor for the Color class
--- @param r number Red component (0 to 255)
--- @param g number Green component (0 to 255)
--- @param b number Blue component (0 to 255)
--- @param a number? Alpha component (0 to 255)
function Color:init(r, g, b, a)
  self.r = (r or 255) / 255
  self.g = (g or 255) / 255
  self.b = (b or 255) / 255
  self.a = (a or 255) / 255

  self[1] = self.r
  self[2] = self.g
  self[3] = self.b
  self[4] = self.a
end

-- --------------------------------- GETTERS -------------------------------- --

function Color:as_table()
  return {self.r, self.g, self.b, self.a}
end

function Color:as_named_table()
  return {r = self.r, g = self.g, b = self.b, a = self.a}
end

-- ----------------------------- FACTORY METHODS ---------------------------- --

--- Creates a Color instance from a hex string
--- @param hex string Hex string in the format "#RRGGBB" or "#RRGGBBAA"
--- @return Color
function Color:from_hex(hex)
  hex = hex:gsub("#", "")
  local r = tonumber(hex:sub(1, 2), 16) / 255
  local g = tonumber(hex:sub(3, 4), 16) / 255
  local b = tonumber(hex:sub(5, 6), 16) / 255
  local a = 1
  if #hex == 8 then
    a = tonumber(hex:sub(7, 8), 16) / 255
  end
  return Color(r, g, b, a)
end

--- Creates a Color instance from LOVE2D color values
--- @param r number Red component (0 to 1)
--- @param g number Green component (0 to 1)
--- @param b number Blue component (0 to 1)
--- @param a number? Alpha component (0 to 1)
--- @return Color
function Color:from_love(r, g, b, a)
  return Color(r * 255, g * 255, b * 255, (a or 1) * 255)
end

-- ----------------------------- SPECIAL METHODS ---------------------------- --

function Color:__tostring()
  return string.format("Color(r: %.2f, g: %.2f, b: %.2f, a: %.2f)",
  self.r * 255, self.g * 255, self.b * 255, self.a * 255)
end


-- ---------------------------- PREDEFINED COLORS --------------------------- --

Color.white         = Color(255, 255, 255)
Color.black         = Color(0, 0, 0)
Color.red           = Color(255, 0, 0)
Color.green         = Color(0, 255, 0)
Color.blue          = Color(0, 0, 255)
Color.yellow        = Color(255, 255, 0)
Color.cyan          = Color(0, 255, 255)
Color.magenta       = Color(255, 0, 255)
Color.gray          = Color(128, 128, 128)
Color.orange        = Color(255, 128, 0)
Color.purple        = Color(128, 0, 128)
Color.brown         = Color(153, 76, 0)
Color.pink          = Color(255, 192, 203)
Color.transparent   = Color(0, 0, 0, 0)
