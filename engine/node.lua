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

  -- Transforms
  self.transform = Transform()
  self.global_transform = Transform()

  -- Rect
  self.rect = Rect()

  -- Init property system
  self:init_properties()

  -- Define transform property aliases
  self:define_property("position",
    function(self) return self.transform.position end,
    function(self, value)
      -- Set position value
      self.transform.position = value
      self.rect.position = value
      -- Update global position based on parent's global position
      if self.parent then
        self.global_transform.position = self.parent.global_transform.position + value
      else
        self.global_transform.position = value
      end
    end
  )

  self:define_property("rotation",
    function(self) return self.transform.rotation end,
    function(self, value)
      self.transform.rotation = value
      -- Update global rotation based on parent's global rotation
      if self.parent then
        self.global_transform.rotation = self.parent.global_transform.rotation + value
      else
        self.global_transform.rotation = value
      end
    end
  )

  self:define_property("scale",
    function(self) return self.transform.scale end,
    function(self, value)
      self.transform.scale = value
      -- Update global scale based on parent's global scale
      if self.parent then
        self.global_transform.scale = Vector2(
          self.parent.global_transform.scale.x * value.x,
          self.parent.global_transform.scale.y * value.y
        )
      else
        self.global_transform.scale = value
      end
    end
  )

  self:define_property("pivot",
    function(self) return self.transform.pivot end,
    function(self, value)
      self.transform.pivot = value
      -- Pivot does not affect global transform directly
    end
  )

  -- Define global transform property aliases
  self:define_property("global_position",
    function(self) return self.global_transform.position end,
    function(self, value)
      self.global_transform.position = value
      -- Update local position based on parent's global position
      if self.parent then
        self.transform.position = value - self.parent.global_transform.position
        self.rect.position = self.transform.position
      else
        self.transform.position = value
        self.rect.position = value
      end
    end
  )

  self:define_property("global_rotation",
    function(self) return self.global_transform.rotation end,
    function(self, value)
      self.global_transform.rotation = value
      -- Update local rotation based on parent's global rotation
      if self.parent then
        self.transform.rotation = value - self.parent.global_transform.rotation
      else
        self.transform.rotation = value
      end
    end
  )

  self:define_property("global_scale",
    function(self) return self.global_transform.scale end,
    function(self, value)
      self.global_transform.scale = value
      -- Update local scale based on parent's global scale
      if self.parent then
        self.transform.scale = Vector2(
          value.x / self.parent.global_transform.scale.x,
          value.y / self.parent.global_transform.scale.y
        )
      else
        self.transform.scale = value
      end
    end
  )

  -- Global pivot should not be used.

  -- Define rect property aliases
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
  if child.on_added then child.on_added() end
end

--- Removes a child node from this node
--- @param child Node
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

--- Removes this node from its parent
function Node:remove_from_parent()
  if self.parent then
    self.parent:remove_child(self)
  end
end

--- Reparents this node to a new parent
--- @param new_parent Node
function Node:reparent(new_parent)
  self:remove_from_parent()
  new_parent:add_child(self)
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
  return self.rect:get_bounds()
end

--- Checks if a given point is within the bounds of the control
--- @param point Vector2 The point to check
--- @return boolean True if the point is within bounds, false otherwise
function Node:is_in_bounds(point)
  return self.rect:has_point(point)
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

  local choice = color or Color.red
  love.graphics.setColor(choice.r, choice.g, choice.b, choice.a)
  love.graphics.setLineWidth(2)
  local bounds = self:get_bounds()
  love.graphics.rectangle("line", bounds.position.x, bounds.position.y, bounds.size.x * self.global_transform.scale.x, bounds.size.y * self.global_transform.scale.y)
  love.graphics.setColor(1, 1, 1, 1)
end
