---@class Game : Class
Game = Class:extend()

function Game:init()
  G = self
  self:set_globals()
end

function Game:start_up()
  S = SceneManager()

  S:change_scene("DragTestScene")
end

function Game:update(dt)
  S:update(dt)
end

function Game:draw()
  S:draw()
end
