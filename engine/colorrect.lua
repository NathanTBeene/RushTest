---@class ColorRect : Control
ColorRect = Control:extend("ColorRect")

---* The ColorRect uses the transform and rect properties of Control to draw a colored rectangle.

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

-- --------------------------------- SETTERS -------------------------------- --

--- Changes the color of the ColorRect.
--- @param new_color Color The new color to set.
function ColorRect:set_color(new_color)
  self.color = new_color
end

-- ------------------------------- LOVE HOOKS ------------------------------- --

function ColorRect:_draw()
  if not self.active then return end

  love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.color.a)
  love.graphics.push()

  -- Move to the object's position
  love.graphics.translate(self.position.x, self.position.y)

  -- Move to the pivot point
  love.graphics.translate(self.pivot.x, self.pivot.y)

  -- Rotate around the pivot
  love.graphics.rotate(self.rotation)

  -- Move back from the pivot point
  love.graphics.translate(-self.pivot.x, -self.pivot.y)

  -- Draw the rectangle
  love.graphics.rectangle("fill", 0, 0, self.width * self.scale.x, self.height * self.scale.y)
  love.graphics.pop()
  self.super._draw(self)
end
