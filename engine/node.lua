---@class Node : Class
Node = Class:extend("Node")

local PropertyMixin = require("engine.mixins.property")
Node:implement(PropertyMixin)

--* Nodes represent any object that needs to have a transform.
--* Everything on screen is a Node.
--* Nodes have a Transform and Rect to represent their position and size in 2D space.
--* Nodes can have child Nodes, forming a scene graph hierarchy.

--- Constructor for the Node class
function Node:init()
  self.parent = nil
  self.children = {}
  self.active = true
  self.debug = G.debug or false
  self.input_behavior = "pass" -- Options: "consume", "pass", "ignore"

  -- Config table for metadata
  self.config = self.config or {}

  -- Local Transform Values (stored directly)
  self._position = Vector2(0, 0)
  self._rotation = 0
  self._scale = Vector2(1, 1)
  self._skew = Vector2(0, 0)
  self._pivot = Vector2(0, 0)

  -- Cached global transform values
  self._global_position = Vector2(0, 0)
  self._global_rotation = 0

  self._global_scale = Vector2(1, 1)

  -- Dirty Flags
  self._global_dirty = true

  -- Rect
  self.rect = Rect()

  -- Init property system
  self:init_properties()
end

-- -------------------------- PROPERTY DEFINITIONS -------------------------- --

Node:define_property("position",
  function(self) return self._position end,
  function(self, value)
    self._position = value
    self:_mark_global_dirty()
  end
)

Node:define_property("rotation",
  function(self) return self._rotation end,
  function(self, value)
    self._rotation = value
    self:_mark_global_dirty()
  end
)

Node:define_property("rotation_degrees",
  function(self) return math.deg(self._rotation) end,
  function(self, value)
    self._rotation = math.rad(value)
    self:_mark_global_dirty()
  end,
  { proxy = false } -- Calculated property, no need to proxy
)

Node:define_property("scale",
  function(self) return self._scale end,
  function(self, value)
    self._scale = value
    self:_mark_global_dirty()
  end
)

Node:define_property("skew",
  function(self) return self._skew end,
  function(self, value)
    self._skew = value
    self:_mark_global_dirty()
  end
)

Node:define_property("pivot",
  function(self) return self._pivot end,
  function(self, value)
    self._pivot = value
    self:_mark_global_dirty()
  end
)

-- Global Transform Properties (Computed on demand)
Node:define_property("global_position",
  function(self)
    self:_update_global_transform()
    return self._global_position
  end,
  function(self, value)
    if self.parent then
      -- Convert global to local
      self._position = value - self.parent.global_position
    else
      self._position = value
    end
    self:_mark_global_dirty()
  end
)

Node:define_property("global_rotation",
  function(self)
    self:_update_global_transform()
    return self._global_rotation
  end,
  function(self, value)
    if self.parent then
      self._rotation = value - self.parent.global_rotation
    else
      self._rotation = value
    end
    self:_mark_global_dirty()
  end,
  { proxy = false }
)

Node:define_property("global_rotation_degrees",
  function(self)
    self:_update_global_transform()
    return math.deg(self._global_rotation)
  end,
  function(self, value)
    local rad = math.rad(value)
    if self.parent then
      self._rotation = rad - self.parent.global_rotation
    else
      self._rotation = rad
    end
    self:_mark_global_dirty()
  end,
  { proxy = false }
)

Node:define_property("global_scale",
  function(self)
    self:_update_global_transform()
    return self._global_scale
  end,
  function(self, value)
    if self.parent then
      self._scale = Vector2(
        value.x / self.parent.global_scale.x,
        value.y / self.parent.global_scale.y
      )
    else
      self._scale = value
    end
    self:_mark_global_dirty()
  end
)

-- Rect Properties
Node:define_property("size",
  function(self) return self.rect.size end,
  function(self, value) self.rect.size = value end
)

Node:define_property("width",
  function(self) return self.rect.size.x end,
  function(self, value) self.rect.size.x = value end
)

Node:define_property("height",
  function(self) return self.rect.size.y end,
  function(self, value) self.rect.size.y = value end
)

-- ---------------------------- TRANSFORM SYSTEM ---------------------------- --

function Node:_mark_global_dirty()
  if self._global_dirty then return end

  self._global_dirty = true

  -- Mark children as dirty
  for _, child in ipairs(self.children) do
    child:_mark_global_dirty()
  end
end

function Node:_update_global_transform()
  if not self._global_dirty then return end -- Already up to date

  if self.parent then
    -- Make sure parent is updated first
    self.parent:_update_global_transform()

    -- Calculate global transform from parent
    local parent_pos = self.parent._global_position
    local parent_rot = self.parent._global_rotation
    local parent_scale = self.parent._global_scale

    -- Apply parent rotation to position offset
    local cos_rot = math.cos(parent_rot)
    local sin_rot = math.sin(parent_rot)
    local rotated_pos = Vector2(
      self._position.x * cos_rot - self._position.y * sin_rot,
      self._position.x * sin_rot + self._position.y * cos_rot
    )

    -- Scale rotated position
    rotated_pos.x = rotated_pos.x * parent_scale.x
    rotated_pos.y = rotated_pos.y * parent_scale.y

    self._global_position = parent_pos + rotated_pos
    self._global_rotation = parent_rot + self._rotation
    self._global_scale = Vector2(
      parent_scale.x * self._scale.x,
      parent_scale.y * self._scale.y
    )
  else
    -- No parent, local is global
    self._global_position = self._position
    self._global_rotation = self._rotation
    self._global_scale = self._scale
  end

  -- Update rect position
  self.rect.position = self._global_position

  self._global_dirty = false
end

-- Forces an update of the global transform immediately
function Node:update_transforms()
  self:_update_global_transform()
  for _, child in ipairs(self.children) do
    child:update_transforms()
  end
end

-- ------------------------- LOVE LIFECYCLE METHODS ------------------------- --

--- Called when the node is loaded
function Node:load()
  self:_load()
  for _, child in ipairs(self.children) do
    child:load()
  end
end

--- Called every frame to update the node
function Node:update(dt)
  if not self.active then return end
  self:_update(dt)
  for i = #self.children, 1, -1 do
    self.children[i]:update(dt)
  end
end

--- Called every frame to draw the node as well as its children
function Node:draw()
  if not self.active then return end
  -- Update transforms before drawing
  self:_update_global_transform()

  self:draw_bounding_rect(Color.red)
  self:_draw()
  for _, child in ipairs(self.children) do
    child:draw()
  end
end

function Node:input(event)
  if not self.active or event:is_consumed() then return end
  -- Children first for reverse propagation
  for i = #self.children, 1, -1 do
    self.children[i]:input(event)
    if event:is_consumed() then return end
  end

  -- Handle based on own input_behavior
  if self.input_behavior == "ignore" then
    return -- Skips _input since already propogated
  end

  -- Call Hook
  self:_input(event)

  -- Consume
  if self.input_behavior == "consume" then
    event:consume()
  end

  -- Pass does nothing and event continues propagating
end

-- ---------------------------------- HOOKS --------------------------------- --
--- Hooks are meant to be used by subclasses to implement custom behavior
--- while keeping the main lifecycle methods intact.

function Node:_load()
  -- Override in subclasses
end

function Node:_update(dt)
  -- Override in subclasses
end

function Node:_draw()
  -- Override in subclasses
end

function Node:_input(event)
  -- Override in subclasses
end

-- ---------------------------- CHILD MANAGEMENT ---------------------------- --

--- Adds another node as a child of this node
--- @param child Node
function Node:add_child(child)
  table.insert(self.children, child)
  child.parent = self
  child:_mark_global_dirty() -- Ensure child's global transform is updated
  if child.on_added then child.on_added() end
end

--- Removes a child node from this node
--- @param child Node
function Node:remove_child(child)
  for i, c in ipairs(self.children) do
    if c == child then
      table.remove(self.children, i)
      child.parent = nil
      child:_mark_global_dirty() -- Ensure child's global transform is updated
      if child.on_removed then child.on_removed() end
      break
    end
  end
end

--- Removes this node from its parent
function Node:remove_from_parent()
  if self.parent then
    self.parent:remove_child(self)
  end
end

--- Reparents this node to a new parent
--- @param new_parent Node
function Node:reparent(new_parent, keep_global_transform)
  if keep_global_transform then
    local cached_pos = self.global_position:clone()
    local cached_rot = self.global_rotation
    local cached_scale = self.global_scale:clone()

    -- Reparent
    self:remove_from_parent()
    new_parent:add_child(self)

    -- Restore global transform
    self.global_position = cached_pos
    self.global_rotation = cached_rot
    self.global_scale = cached_scale
  else
    -- Simple reparent
    self:remove_from_parent()
    new_parent:add_child(self)
  end
end

--- Destroys this node and all its children
function Node:destroy()
  -- Clean children first
  for i = #self.children, 1, -1 do
    self.children[i]:destroy()
  end
  self:remove_from_parent()
end

-- --------------------------- BOUNDARY CHECKERS ---------------------------- --

--- Creates a rectangle representing the bounds of the control in global space
--- @return Rect The bounding rectangle of the control
function Node:get_bounds()
  self:_update_global_transform()
  return self.rect:get_bounds()
end

--- Checks if a given point is within the bounds of the control
--- @param point Vector2 The point to check
--- @return boolean True if the point is within bounds, false otherwise
function Node:is_in_bounds(point)
  self:_update_global_transform()
  return self.rect:has_point(point)
end

-- ----------------------------- HELPER METHODS ----------------------------- --

function Node:translate(offset)
  self.position = self.position + offset
end

function Node:global_translate(offset)
  self.global_position = self.global_position + offset
end

function Node:rotate(radians)
  self.rotation = self.rotation + radians
end

function Node:apply_scale(factor)
  self.scale = Vector2(
    self.scale.x * factor.x,
    self.scale.y * factor.y
  )
end

function Node:to_local(global_point)
  self:_update_global_transform()

  -- Translate to origin
  local local_point = global_point - self._global_position

  -- Rotate by inverse rotation
  local cos_rot = math.cos(-self._global_rotation)
  local sin_rot = math.sin(-self._global_rotation)
  local rotated_point = Vector2(
    local_point.x * cos_rot - local_point.y * sin_rot,
    local_point.x * sin_rot + local_point.y * cos_rot
  )

  -- Scale by inverse scale
  return Vector2(
    self._global_scale.x ~= 0 and rotated_point.x / self._global_scale.x or rotated_point.x,
    self._global_scale.y ~= 0 and rotated_point.y / self._global_scale.y or rotated_point.y
  )
end

function Node:to_global(local_point)
  self:_update_global_transform()

  -- Scale
  local scaled_point = Vector2(
    local_point.x * self._global_scale.x,
    local_point.y * self._global_scale.y
  )

  -- Rotate
  local cos_rot = math.cos(self._global_rotation)
  local sin_rot = math.sin(self._global_rotation)
  local rotated_point = Vector2(
    scaled_point.x * cos_rot - scaled_point.y * sin_rot,
    scaled_point.x * sin_rot + scaled_point.y * cos_rot
  )

  -- Translate
  return self._global_position + rotated_point
end

-- -------------------------------- DEBUGGING ------------------------------- --

--- Prints the tree structure starting from this node
function Node:print_tree(depth)
  depth = depth or 0
  print(string.rep("  ", depth) .. self.name)
  for _, child in ipairs(self.children) do
    child:print_tree(depth + 1)
  end
end

--- Draws the bounding rectangle of the node for debugging purposes
--- @param color table The color to use for drawing the bounding rectangle
function Node:draw_bounding_rect(color)
  if not self.debug then return end

  self:_update_global_transform()

  local choice = color or Color.red
  love.graphics.setColor(choice.r, choice.g, choice.b, choice.a)
  love.graphics.setLineWidth(2)
  local bounds = self:get_bounds()


  love.graphics.rectangle(
    "line",
    bounds.position.x,
    bounds.position.y,
    bounds.size.x * self.global_scale.x,
    bounds.size.y * self.global_scale.y
  )
  love.graphics.setColor(1, 1, 1, 1)
end
