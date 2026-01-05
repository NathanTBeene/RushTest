---@class Scene: Node
Scene = Node:extend()

-- A scene is a collection of nodes that starts with a single root node.
-- Scenes can contain other scenes since they are themselves just nodes.

---@param root Node
function Scene:init(root)
  self.root = root
  self.objects = {}
end

function Scene:load()
  -- Load all nodes in the scene
  self.root:load()
  for _, obj in pairs(self.objects) do
    obj:load()
  end
end


function Scene:draw()
  self.root:draw()
  for _, obj in pairs(self.objects) do
    obj:draw()
  end
end

function Scene:update(dt)
  self.root:update(dt)
  for _, obj in pairs(self.objects) do
    obj:update(dt)
  end
end


---@class SceneManager
SceneManager = Class:extend()

-- SceneManager Config
-- initial_scene: object { name: string, scene: Scene }

function SceneManager:init(config)
  self.scenes = {}
  self.current_scene = nil

  if config and config.initial_scene then
    self:add_scene(config.initial_scene.name, config.initial_scene.scene)
    self:load_scene(config.initial_scene.name)
  end
end

function SceneManager:load_scene(name)
  local scene = self.scenes[name]
  if scene then
    self.current_scene = scene
    self.current_scene:load()
  else
    Conduit.system:error("[SceneManager] load_scene: Scene '" .. name .. "' not found.")
  end
end

function SceneManager:add_scene(name, scene)
  if type(scene) ~= "table" or scene:is(Scene) == false then
    Conduit.system:error("[SceneManager] add_scene: scene must be of type Scene")
  end

  self.scenes[name] = scene
end

function SceneManager:draw()
  if self.current_scene then
    self.current_scene:draw()
  end
end

function SceneManager:update(dt)
  if self.current_scene then
    self.current_scene:update(dt)
  end
end
