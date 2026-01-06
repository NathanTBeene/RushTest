---@class Game : Class
Game = Class:extend()

function Game:init()
  G = self
end

function Game:start_up()
  test_rect = ColorRect(Color.cyan)
  test_rect.transform.position = Vector2(100, 100)
end

function Game:update(dt)
end

function Game:draw()
  test_rect:draw()
end

function Game:key_pressed(key)
end

function Game:key_released(key)
end

function Game:mouse_pressed(x, y, button)
end

function Game:mouse_released(x, y, button)
end
