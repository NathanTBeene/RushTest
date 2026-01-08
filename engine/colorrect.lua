---@class ColorRect : Control
ColorRect = Control:extend("ColorRect")

--- Constructor for the ColorRect class
---@param color? Color The color of the rectangle (optional, default to Color())
---@param width? number The width of the rectangle (optional, default to 100)
---@param height? number The height of the rectangle (optional, default to 100)
function ColorRect:init(color, width, height)
  ColorRect.super.init(self)
  self.color = color or Color()
  self.transform.width = width or 100
  self.transform.height = height or 100
end


function ColorRect:draw()
  if not self.active then return end
  self.super.draw(self)

  love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
  love.graphics.push()

  -- Move to the object's position
  love.graphics.translate(self.transform.position.x, self.transform.position.y)

  -- Move to the pivot point
  love.graphics.translate(self.transform.pivot.x, self.transform.pivot.y)

  -- Rotate around the pivot
  love.graphics.rotate(self.transform.rotation.y)

  -- Move back from the pivot point
  love.graphics.translate(-self.transform.pivot.x, -self.transform.pivot.y)

  -- Draw the rectangle
  love.graphics.rectangle("fill", 0, 0, self.transform.width * self.transform.scale.x, self.transform.height * self.transform.scale.y)
  love.graphics.pop()
end
