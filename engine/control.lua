---@class Control : Node
Control = Node:extend("Control")

---* Controls are nodes that are considered UI and are specifically meant to be
---* interacted with separately from the rest of the game world. They are on their
---* own layer, and are not affected by the game world's physics or other systems.


local DraggableMixin = require("engine.mixins.draggablemixin")
Control:implement(DraggableMixin)

function Control:init()
  Control.super.init(self)

  -- Controls are represented by Rects
  self.rect = Rect(0, 0, 100, 100)

  -- Aliasing
  self:define_property("size",
    function(self) return Vector2(self.rect.size.x, self.rect.size.y) end,
    function(self, value)
      self.rect.size.x = value.x
      self.rect.size.y = value.y
    end
  )
  self:define_property("width",
    function(self) return self.rect.size.x end,
    function(self, value) self.rect.size.x = value end
  )
  self:define_property("height",
    function(self) return self.rect.size.y end,
    function(self, value) self.rect.size.y = value end
  )

  -- Draggable
  self:init_draggable()
end

-- ---------------------------- LIFECYCLE METHODS --------------------------- --

function Control:_load()
end

function Control:_update(dt)
  self:update_drag()
end

function Control:_draw()
  self:draw_bounds(Color.purple)
end

-- --------------------------- BOUNDARY CHECKERS ---------------------------- --

--- Creates a rectangle representing the bounds of the control in global space
--- @return Rect The bounding rectangle of the control
function Control:get_bounds()
  return self.rect:get_bounds()
end

--- Checks if a given point is within the bounds of the control
--- @param point Vector2 The point to check
--- @return boolean True if the point is within bounds, false otherwise
function Control:is_in_bounds(point)
  return self.rect:has_point(point)
end

-- -------------------------------- CHECKERS -------------------------------- --

--- Checks if the mouse is currently over this control
--- @return boolean True if the mouse is over the control, false otherwise
function Control:is_mouse_over()
  local mousePos = I:get_mouse_position()
  return self:is_in_bounds(mousePos)
end

-- ---------------------------------- DEBUG --------------------------------- --

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
