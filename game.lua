---@class Game : Class
Game = Class:extend("Game")

function Game:init()
  G = self
  self:set_globals()
  self.nodes = {}

  local testNode = ColorRect(Color.white, 200, 150)
  testNode.name = "TestNode"
  testNode.position = Vector2(100, 100)
  testNode.size = Vector2(200, 150)

  local testButton = Button()
  testButton.name = "TestButton"
  testButton.position = Vector2(500, 200)

  self.nodes["testNode"] = testNode
  self.nodes["testButton"] = testButton
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
  for _, node in pairs(self.nodes) do
    node:update(dt)
  end
end

function Game:draw()
  for _, node in pairs(self.nodes) do
    node:draw()
  end
end

function Game:input(event)
  for _, node in pairs(self.nodes) do
    node:input(event)
    if event:is_consumed() then
      break
    end
  end
end
