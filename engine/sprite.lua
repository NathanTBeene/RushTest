---@class Sprite : Control
Sprite = Control:extend("Sprite")

---* A representation of a 2d image within the game.
---* Can be used with a SpriteSheet for animations
---* or atlas images.

--- @param sprite? SpriteSheet The SpriteSheet to use for this sprite.
function Sprite:init(sprite, starting_index)
  Sprite.super.init(self)
  self.sprite_sheet = sprite or nil
  self.sprite_index = starting_index or 1

  self:_set_initial_size()
end


function Sprite:_draw()
  if self.sprite_sheet then
    local sprite = self.sprite_sheet:get_sprite(self.sprite_index)
    if sprite then
      love.graphics.draw(self.sprite_sheet.texture, sprite, self.global_position.x, self.global_position.y)
    end
  end
end

function Sprite:_set_initial_size()
  if self.sprite_sheet then
    local sprite = self.sprite_sheet:get_sprite(self.sprite_index)
    if sprite then
      local _, _, w, h = sprite:getViewport()
      self.width = w
      self.height = h
    end
  end
end
