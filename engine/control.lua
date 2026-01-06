---@class Control : Node
Control = Node:extend()

---* Controls are nodes that are considered UI and are specifically meant to be
---* interacted with separately from the rest of the game world. They are on their
---* own layer, and are not affected by the game world's physics or other systems.

function Control:init()
  Control.super.init(self)
end

--- Checks if the mouse is currently over this control
--- @return boolean True if the mouse is over the control, false otherwise
function Control:is_mouse_over()
  local mousePos = Vector2(love.mouse.getX(), love.mouse.getY())
  return self:is_in_bounds(mousePos)
end
