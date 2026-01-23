---@class Button : Control
Button = Control:extend("Button")


---* Buttons are UI controls that can be clicked by the user.
---* They emit a "clicked" signal when activated.

function Button:init()
  Button.super.init(self)
  self.text = "Button"
  self.text_align = "left" -- "left", "center", "right"

  -- Default Button Properties
  self.size = Vector2(100, 40)
end

function Button:_draw()

  local style = self.style or Style.BUTTON
  local current_state = style.normal

  -- Set color
  love.graphics.setColor(current_state.backgroundColor:as_table())
  love.graphics.push()

  -- Move to the object's position
  love.graphics.translate(self.position.x, self.position.y)

  -- Move to the pivot point
  love.graphics.translate(self.pivot.x, self.pivot.y)

  -- Rotate around the pivot
  love.graphics.rotate(self.rotation)

  -- Move back from the pivot point
  love.graphics.translate(-self.pivot.x, -self.pivot.y)

  -- Draw the button rectangle
  love.graphics.rectangle("fill", 0, 0, self.size.x * self.scale.x, self.size.y * self.scale.y)

  -- Border Rectangle
  love.graphics.setLineWidth(current_state.borderWidth)
  love.graphics.setColor(current_state.borderColor:as_table())

  local padding = current_state.padding

  -- Draw Text Box if debug
  if self.debug then
    love.graphics.setColor(Color.red:as_table())
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line",
      padding.left,
      padding.top,
      self.size.x * self.scale.x - padding.left - padding.right,
      self.size.y * self.scale.y - padding.top - padding.bottom)
  end


  love.graphics.pop()
  self.super._draw(self)
end
