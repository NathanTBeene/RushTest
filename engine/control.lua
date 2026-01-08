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
  local mt = getmetatable(self)
  local original_index = mt.__index

  mt.__index = function(table, key)
    -- Rect Aliasing
    if key == "position" then return rawget(table, "rect").position
    elseif key == "size" then return rawget(table, "rect").size
    end

    -- Fall back to original __index
    if type(original_index) == "function" then
      return original_index(table, key)
    else
      return original_index[key]
    end
  end

  mt.__newindex = function(table, key, value)
    -- Rect Aliasing
    if key == "position" then rawget(table, "rect").position = value
    elseif key == "size" then rawget(table, "rect").size = value
    else
      rawset(table, key, value)
    end
  end
end

-- ---------------------------- LIFECYCLE METHODS --------------------------- --

function Control:_load()
end

function Control:_update(dt)
end

function Control:_draw()
  self:draw_bounds()
end

--- Checks if the mouse is currently over this control
--- @return boolean True if the mouse is over the control, false otherwise
function Control:is_mouse_over()
  local mousePos = Vector2(love.mouse.getX(), love.mouse.getY())
  return self:is_in_bounds(mousePos)
end

--- Draws the bounding rectangle of the control for debugging purposes
function Control:draw_bounds()
  if not self.debug then return end
  love.graphics.setColor(1, 0, 0, 0.5)
  love.graphics.rectangle("line", self.global_position.x, self.global_position.y, self.size.x, self.size.y)
  love.graphics.setColor(1, 1, 1, 1)
end
