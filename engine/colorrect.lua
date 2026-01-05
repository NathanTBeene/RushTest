---@class ColorRect : Control
ColorRect = Control:extend()

---@param color Color
---@param width number
---@param height number
function ColorRect:init(color, width, height)
  ColorRect.super.init(self)
  self.color = color or Color(1, 1, 1, 1)
  -- Width and height will be stored in the transform via the __newindex metamethod
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
