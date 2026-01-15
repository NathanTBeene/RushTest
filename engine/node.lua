---@class Node : Class
Node = Class:extend("Node")

local PropertyMixin = require("engine.mixins.property")
Node:implement(PropertyMixin)

--- Constructor for the Node class
function Node:init()
  self.parent = nil
  self.children = {}
  self.active = true
  self.debug = false

  -- Transforms
  self.transform = Transform()
  self.global_transform = Transform()

  -- Init property system
  self:init_properties()

  -- Define transform property aliases
  self:define_property("position",
    function(self) return self.transform.position end,
    function(self, value)
      -- Set position value
      self.transform.position = value
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
      else
        self.transform.position = value
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
  self:update_transforms(dt)
  for i = #self.children, 1, -1 do
    self.children[i]:update(dt)
  end
end

--- Called every frame to draw the node as well as its children
function Node:draw()
  if not self.active then return end
  self:_draw()
  for _, child in ipairs(self.children) do
    child:draw()
  end
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

--- Updates the transforms of children to reflect any changes in this node's transform
--- @param dt number Delta time since last update
function Node:update_transforms(dt)

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

-- ----------------------------- SPECIAL METHODS ---------------------------- --

function Node:__tostring()
  local name = self.__name or "Node"
  return string.format("<%s: %s>", name, tostring(self.transform.position))
end

--- Internal method for calculating global position
--- from screen space
function Node:_get_global_position()

end
