---@class Node
Node = Class:extend()

function Node:init()
  self.parent = nil
  self.children = {}
  self.transform = Transform()
  self.active = true
  self.debug = false
  self.name = ""
end

function Node:load()
end

function Node:add_child(child)
  table.insert(self.children, child)
  child.parent = self
  if child.on_added then child.on_added() end
end

function Node:remove_child(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      child.parent = nil
      if child.on_removed then child.on_removed() end
      break
    end
  end
end

function Node:remove_from_parent()
  if self.parent then
    self.parent:remove_child(self)
  end
end

function Node:update(dt)
  if not self.active then return end
  for i = #self.children, 1, -1 do
    self.children[i]:update(dt)
  end
end

function Node:draw()
  if not self.active then return end

  self:draw_bounds()

  for _, child in ipairs(self.children) do
    child:draw()
  end
end

function Node:destroy()
  -- Clean children first
  for i = #self.children, 1, -1 do
    self.children[i]:destroy()
  end
  self:remove_from_parent()
end

function Node:reparent(new_parent)
  self:remove_from_parent()
  new_parent:add_child(self)
end

function Node:print_tree(depth)
  depth = depth or 0
  print(string.rep("  ", depth) .. self.name)
  for _, child in ipairs(self.children) do
    child:print_tree(depth + 1)
  end
end

function Node:draw_bounds()
  if not self.debug then return end

  local corners = self:get_bounds()
  love.graphics.setColor(0, 1, 0, 1)

  for i = 1, #corners do
    local next_i = (i % #corners) + 1
    love.graphics.line(corners[i].x, corners[i].y, corners[next_i].x, corners[next_i].y)
  end

  love.graphics.setColor(1, 1, 1, 1)
end

--- Getters

-- Returns a table with Vector2 points for the corners of the bounding box
---@return table
function Node:get_bounds()
  local w = self.transform.width * self.transform.scale.x
  local h = self.transform.height * self.transform.scale.y
  local rot = self.transform.rotation.y
  local px, py = self.transform.pivot.x, self.transform.pivot.y
  local pos = self.transform.position

  local corners = {
    Vector2(0,0),
    Vector2(w,0),
    Vector2(w,h),
    Vector2(0,h)
  }

  -- Transform each corner.
  local transformed_corners = {}
  local cos_r = math.cos(rot)
  local sin_r = math.sin(rot)

  for i, corner in ipairs(corners) do
    -- Translate to pivot
    local lx = corner.x - px
    local ly = corner.y - py

    -- Rotate
    local rx = lx * cos_r - ly * sin_r
    local ry = lx * sin_r + ly * cos_r

    -- Translate back and apply position
    transformed_corners[i] = Vector2(rx + px + pos.x, ry + py + pos.y)
  end

  return transformed_corners
end

-- State Checkers

---@param point Vector2
function Node:is_in_bounds(point)
  -- 1. Get properties
  local w = self.transform.width * self.transform.scale.x
  local h = self.transform.height * self.transform.scale.y
  local rot = self.transform.rotation.y
  local px, py = self.transform.pivot.x, self.transform.pivot.y
  local pos = self.transform.position

  -- 2. Translate point to local space
  local lx = point.x - pos.x
  local ly = point.y - pos.y

  -- 3. Translate to pivot
  lx = lx - px
  ly = ly - py

  -- 4. Rotate point in opposite direction
  local cos_r = math.cos(-rot)
  local sin_r = math.sin(-rot)
  local rx = lx * cos_r - ly * sin_r
  local ry = lx * sin_r + ly * cos_r

  -- 5. Traslate back from pivot
  rx = rx + px
  ry = ry + py

  -- 6. Check bounds
  return rx >= 0 and rx <= w and ry >= 0 and ry <= h
end
