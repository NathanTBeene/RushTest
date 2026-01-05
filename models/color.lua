---@class Color
Color = Class:extend()

function Color:init(r, g, b, a)
  self.r = r or 1
  self.g = g or 1
  self.b = b or 1
  self.a = a or 1

  self[1] = self.r
  self[2] = self.g
  self[3] = self.b
  self[4] = self.a
end

function Color:__tostring()
  return string.format("Color(r: %.2f, g: %.2f, b: %.2f, a: %.2f)", self.r, self.g, self.b, self.a)
end

Color.white = Color(1, 1, 1, 1)
Color.black = Color(0, 0, 0, 1)
Color.red    = Color(1, 0, 0, 1)
Color.green  = Color(0, 1, 0, 1)
Color.blue   = Color(0, 0, 1, 1)
Color.yellow = Color(1, 1, 0, 1)
Color.cyan   = Color(0, 1, 1, 1)
Color.magenta= Color(1, 0, 1, 1)
Color.gray   = Color(0.5, 0.5, 0.5, 1)
Color.orange = Color(1, 0.5, 0, 1)
Color.purple = Color(0.5, 0, 0.5, 1)
Color.brown  = Color(0.6, 0.3, 0, 1)
Color.pink   = Color(1, 0.75, 0.8, 1)
Color.transparent = Color(0, 0, 0, 0)
