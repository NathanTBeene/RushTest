---@class Game
Game = Class:extend()

function Game:init()
  G = self

  self:set_globals()
end

function Game:start_up()

  local testRoot = Node()
  local testRect = ColorRect(Color(0, 255, 0), 100, 100)
  testRect.transform.position = Vector2(200, 150)
  testRoot:add_child(testRect)
  local testScene = Scene(testRoot)

  -- Load assets, initialize systems
  self.E_MANAGER = EventManager:init()
  self.S_MANAGER = SceneManager:init({
    initial_scene = { name = "test", scene = testScene }
  })
end

function Game:update(dt)
end

function Game:draw()
end

function Game:key_pressed(key)
end

function Game:key_released(key)
end

function Game:mouse_pressed(x, y, button)
end

function Game:mouse_released(x, y, button)
end
