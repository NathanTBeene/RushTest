---@class Scene: Node
Scene = Node:extend()

-- A scene is a collection of nodes that starts with a single root node.
-- Scenes can contain other scenes since they are themselves just nodes.

---@param root Node
function Scene:init(root)
  self.root = root
  self.objects = {}
end
