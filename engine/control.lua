---@class Control : Node
Control = Node:extend("Control")

---* Controls are nodes that are considered UI and are specifically meant to be
---* interacted with separately from the rest of the game world. They are on their
---* own layer, and are not affected by the game world's physics or other systems.

function Control:init()
  Control.super.init(self)

  -- Controls are represented by Rects
  self.rect = Rect(0, 0, 100, 100)

  -- Aliasing
  self:define_property("size",
    function(self) return Vector2(self.rect.width, self.rect.height) end,
    function(self, value)
      self.rect.width = value.x
      self.rect.height = value.y
    end
  )
  self:define_property("width",
    function(self) return self.rect.width end,
    function(self, value) self.rect.width = value end
  )
  self:define_property("height",
    function(self) return self.rect.height end,
    function(self, value) self.rect.height = value end
  )
end

-- ---------------------------- LIFECYCLE METHODS --------------------------- --

function Control:_load()
end

function Control:_update(dt)
end

function Control:_draw()
  self:draw_bounds(Color.purple)
end

--- Checks if the mouse is currently over this control
--- @return boolean True if the mouse is over the control, false otherwise
function Control:is_mouse_over()
  local mousePos = Vector2(love.mouse.getX(), love.mouse.getY())
  return self:is_in_bounds(mousePos)
end

--- Draws the bounding rectangle of the control for debugging purposes
function Control:draw_bounds(color, thickness)
  if not self.debug then return end

  local choice = color or Color.red
  local thick = thickness or 2

  love.graphics.setColor(choice.r, choice.g, choice.b, choice.a)
  love.graphics.setLineWidth(thick)
  love.graphics.rectangle("line", self.global_position.x, self.global_position.y, self.size.x, self.size.y)
  love.graphics.setColor(1, 1, 1, 1)
end
