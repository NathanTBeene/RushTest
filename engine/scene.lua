---@class Scene : Node
Scene = Node:extend("Scene")

---* Scenes are just base Nodes that are intended to be used as the root node of a scene graph.
---* Individual scenes are subclasses of Scene.

function Scene:init()
  self.name = "Scene"
  Scene.super.init(self)
end

--- Called when switching to scene.
--- To be overridden by subclasses.
function Scene:_enter()
end

--- Called when switching away from scene.
--- To be overridden by subclasses.
function Scene:_exit()
end

-- ---------------------------- SCENE DEFINITIONS --------------------------- --

Scene.MAIN_MENU = 1
Scene.GAMEPLAY = 2

-- ------------------------------ SCENE MANAGER ----------------------------- --
---@class SceneManager : Class
SceneManager = Class:extend("SceneManager")

---* SceneManager handles switching between different scenes in the game.
---* Keeps track of current scene and any other scenes that are currently
---* loaded in memory.

--- Initializes the SceneManager.
--- @param initial_scene? Scene The initial scene to set as current.
function SceneManager:init(initial_scene)
  self.scene_classes = {}   -- Registered Scenes
  self.scenes = {}          -- Instantiated Scenes
  self.current_scene = initial_scene or nil
end

--- Registers a scene class with the SceneManager.
--- @param name string Name of the scene.
function SceneManager:register_scene(name, class)
  self.scene_classes[name] = class
end

--- Loads a scene into memory asynchronously.
--- @param name string Name of the scene to load.
function SceneManager:load_scene(name)
  if not self.scenes[name] and self.scene_classes[name] then
    -- Simulate async loading with a coroutine
    local co = coroutine.create(function()
      love.timer.sleep(0.1)  -- Simulated loading delay
      self.scenes[name] = self.scene_classes[name]()
    end)

    coroutine.resume(co)
  end
end

--- Unloads a scene from memory.
--- @param scene_name string Name of the scene to unload.
function SceneManager:unload_scene(scene_name)
  self.scenes[scene_name] = nil
end

--- Instansiates and switches to a new scene.
--- Calls _exit on the current scene and _enter on the new scene.
--- @param scene_name string Name of the scene to switch to.
--- @param unload boolean Whether to unload the previous scene from memory.
function SceneManager:change_scene(scene_name, unload)
  if not self.scene_classes[scene_name] then
    Conduit.system:error("Scene '" .. scene_name .. "' is not registered.")
    return
  end

  if self.current_scene then
    self.current_scene:_exit()

    -- Unload previous scene if specified
    if unload then
      for name, scene in pairs(self.scenes) do
        if scene == self.current_scene then
          self:unload_scene(name)
          break
        end
      end
    end
  end

  if not self.scenes[scene_name] then
    self:load_scene(scene_name)
  end

  self.current_scene = self.scenes[scene_name]

  if self.current_scene then
    self.current_scene:_enter()
  end
end
