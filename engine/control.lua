---@class Control : Node
Control = Node:extend("Control")

---* Controls are nodes that are considered UI and are specifically meant to be
---* interacted with separately from the rest of the game world. They are on their
---* own layer, and are not affected by the game world's physics or other systems.

function Control:init()
  Control.super.init(self)

end

-- ---------------------------- LIFECYCLE METHODS --------------------------- --

function Control:_load()
end

function Control:_update(dt)
end

function Control:_draw()
end

-- -------------------------------- CHECKERS -------------------------------- --

--- Checks if the mouse is currently over this control
--- @return boolean True if the mouse is over the control, false otherwise
function Control:is_mouse_over()
  local mousePos = I:get_mouse_position()
  return self:is_in_bounds(mousePos)
end
