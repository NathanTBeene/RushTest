---@class Game : Class
Game = Class:extend()

function Game:init()
  G = self
  self:set_globals()
end

function Game:start_up()
  S = SceneManager()

  scene = Scene("MainScene")
  S:change_scene(scene)

  local control = Control()
  control.debug = true
  control.position = Vector2(100, 100)
  control.size = Vector2(200, 200)
  scene:add_child(control)

  local child = Control()
  child.debug = true
  child.position = Vector2(50, 50)
  child.size = Vector2(100, 100)
  control:add_child(child)

  child.global_position = Vector2(300, 300)


  Conduit.system:watch("Child Position", function() return child.position end)
  Conduit.system:watch("Child Global Position", function() return child.global_position end)
end

function Game:update(dt)
  S:update(dt)
end

function Game:draw()
  S:draw()
end

function Game:key_pressed(key)
end

function Game:key_released(key)
end

function Game:mouse_pressed(x, y, button)
end

function Game:mouse_released(x, y, button)
end
