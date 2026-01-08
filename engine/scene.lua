---@class Scene : Class
Scene = Class:extend("Scene")

---* A Scene is the root node of a scene graph. It contains all nodes that are part
---* of the scene organized in a tree structure.

function Scene:init(base_node)
  Scene.super.init(self)
  self.root = base_node or Node()
end

function Scene:load()
  if G.debug then
    Conduit.system:log("Loading Scene " .. tostring(self))
  end
  self.root:load()
end

function Scene:update(dt)
  self.root:update(dt)
end

function Scene:draw()
  self.root:draw()
end

function Scene:destroy()
  self.root:destroy()
  Scene.super.destroy(self)
end

function Scene:add_child(child)
  self.root:add_child(child)
end

function Scene:remove_child(child)
  self.root:remove_child(child)
end

function Scene:__tostring()
  return "Scene@" .. self.__name
end


--- @class SceneManager : Class
SceneManager = Class:extend("SceneManager")

---* The SceneManager handles switching between different scenes in the game.
---
---* It keeps track of the current scene and allows for loading, updating,
---* drawing, and destroying scenes as needed.

function SceneManager:init()
  SceneManager.super.init(self)
  self.current_scene = nil
end

function SceneManager:load()
  if self.current_scene then
    self.current_scene:load()
  end
end

function SceneManager:update(dt)
  if self.current_scene then
    self.current_scene:update(dt)
  end
end

function SceneManager:draw()
  if self.current_scene then
    self.current_scene:draw()
  end
end

function SceneManager:destroy()
  if self.current_scene then
    self.current_scene:destroy()
    self.current_scene = nil
  end
end

function SceneManager:change_scene(new_scene)
  if self.current_scene then
    self.current_scene:destroy()
  end
  self.current_scene = new_scene
  self.current_scene:load()
end
