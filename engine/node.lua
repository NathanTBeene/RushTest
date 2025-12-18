---@class Node
Node = Class:extend()

function Node:init()
  self.parent = nil
  self.children = {}
  self.transform = Transform()
  self.active = true
  self.name = ""
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
