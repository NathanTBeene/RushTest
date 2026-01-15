---@class Game : Class
Game = Class:extend()

function Game:init()
  G = self
  self:set_globals()
end

function Game:start_up()
  S = SceneManager()

  scene = Scene("MainScene")
  scene.debug = true
  S:change_scene(scene)

  control = Control("ParentControl")
  control.debug = true
  control.position = Vector2(100, 100)
  control.size = Vector2(200, 200)
  scene:add_child(control)

  child = ColorRect("ChildControl", Color.green)
  child.debug = true
  child.position = Vector2(50, 50)
  child.size = Vector2(100, 100)
  control:add_child(child)

  Conduit.system:group("Parent Node", 1)
  Conduit.system:watch("Parent Position", function() return control.position end, "Parent Node", 1)
  Conduit.system:watch("Parent Global Position", function() return control.global_position end, "Parent Node", 2)

  Conduit.system:group("Child Node", 2)
  Conduit.system:watch("Child Position", function() return child.position end, "Child Node", 1)
  Conduit.system:watch("Child Global Position", function() return child.global_position end, "Child Node", 2)


  Conduit.system:watch("Calculated Offset", function() return child.global_position - control.global_position end, "Child Node", 3)
end

function Game:update(dt)
  S:update(dt)

  -- if child.position.x < 600 then
  --   child.position = child.position + Vector2.RIGHT * dt * 50
  -- end

  -- if control.position.x < 600 then
  --   control.position = control.position + Vector2.RIGHT * dt * 50
  -- end
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
