---@class Node : Class
Node = Class:extend("Node")

--- Constructor for the Node class
function Node:init()
  self.parent = nil
  self.children = {}
  self.active = true
  self.debug = false

  -- Transforms
  self.transform = Transform()
  self.global_transform = Transform()

  -- Property Aliasing
  local mt = getmetatable(self)
  local original_index = mt.__index

  mt.__index = function(table, key)
    -- Local Transform Aliasing
    if key == "position" then return rawget(table, "transform").position
    elseif key == "rotation" then return rawget(table, "transform").rotation
    elseif key == "scale" then return rawget(table, "transform").scale

    -- Global Transform Aliasing
    elseif key == "global_position" then return rawget(table, "global_transform").position
    elseif key == "global_rotation" then return rawget(table, "global_transform").rotation
    elseif key == "global_scale" then return rawget(table, "global_transform").scale
    end

    -- Fall back to original __index
    if type(original_index) == "function" then
      return original_index(table, key)
    else
      return original_index[key]
    end
  end

  mt.__newindex = function(table, key, value)
    -- Local Transform Aliasing
    if key == "position" then rawget(table, "transform").position = value
    elseif key == "rotation" then rawget(table, "transform").rotation = value
    elseif key == "scale" then rawget(table, "transform").scale = value

    -- Global Transform Aliasing
    elseif key == "global_position" then rawget(table, "global_transform").position = value
    elseif key == "global_rotation" then rawget(table, "global_transform").rotation = value
    elseif key == "global_scale" then rawget(table, "global_transform").scale = value

    else
      rawset(table, key, value)
    end
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
  -- Update global transform based on parent's global transform
  if self.parent then
    self.global_transform.position = self.parent.global_transform.position + self.position
    self.global_transform.rotation = self.parent.global_transform.rotation + self.rotation
    self.global_transform.scale = Vector2(
      self.parent.global_transform.scale.x * self.scale.x,
      self.parent.global_transform.scale.y * self.scale.y
    )
  else
    self.global_transform.position = self.position
    self.global_transform.rotation = self.rotation
    self.global_transform.scale = self.scale
  end
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
  return "Node: " .. self.__name
end
