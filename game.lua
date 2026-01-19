---@class Game : Class
Game = Class:extend()

function Game:init()
  G = self
  self:set_globals()
end

function Game:start_up()
  -- Set Input Actions
  I:load_actions({
    move_left = {keyboard = {"a", "left"}},
    move_right = {keyboard = {"d", "right"}},
    move_up = {keyboard = {"w", "up"}},
    move_down = {keyboard = {"s", "down"}},
    jump = {keyboard = {"space"}},
    attack = {mouse = {1}, keyboard = {"z"}},
    pause = {keyboard = {"escape"}}
  })
end

function Game:update(dt)
end

function Game:draw()
end
