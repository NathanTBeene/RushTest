---@class Game : Class
Game = Class:extend("Game")

function Game:init()
  G = self
  self:set_globals()
  self.nodes = {}

  local base_sprites = SpriteSheet("assets/base.png", {hSplit = 7, vSplit = 5})
  local suit_sprites = SpriteSheet("assets/deck.png", {hSplit = 13, vSplit = 4})

  local test_sprite = Sprite(base_sprites, 2)
  test_sprite.name = "Base Sprite"
  local deck_sprite = Sprite(suit_sprites, 10)
  deck_sprite.name = "Deck Sprite"

  Conduit.gameplay:group("Base Sprite", 1)
  Conduit.gameplay:watch("base_sprite_position", function()
    return test_sprite.position
  end, "Base Sprite", 1)
  Conduit.gameplay:watch("base_sprite_global_position", function()
    return test_sprite.global_position
  end, "Base Sprite", 2)

  Conduit.gameplay:group("Deck Sprite", 2)
  Conduit.gameplay:watch("deck_sprite_position", function()
    return deck_sprite.position
  end, "Deck Sprite", 1)
  Conduit.gameplay:watch("deck_sprite_global_position", function()
    return deck_sprite.global_position
  end, "Deck Sprite", 2)

  test_sprite:add_child(deck_sprite)
  test_sprite.position = Vector2(100, 100)
  deck_sprite.position = Vector2(100, 0)
  table.insert(self.nodes, test_sprite)
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

  -- test move
  local sprite = self.nodes[1]
  local speed = 5

  sprite.global_position.x = sprite.global_position.x + speed * dt
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
