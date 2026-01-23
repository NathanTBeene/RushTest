---@class SpriteSheet : Class
SpriteSheet = Class:extend("SpriteSheet")

---* A representation of a collection of sprites within a single image file.
---* Used to optimize rendering by reducing texture swaps.
---* Sprite is split into a grid based on the number of horizontal and vertical splits.
---* Each cell in the grid represents an individual sprite.

---@param texture_url string The file path to the texture image.
---@param config? {index: number, hSplit: number, vSplit: number, spacing: {top: number, bottom: number, left: number, right: number}} Optional configuration table.
function SpriteSheet:init(texture_url, config)
  self.texture = nil
  self.sprites = {}

  self.index = config and config.index or 1 -- Current sprite index
  self.vSplit = config and config.vSplit or 1 -- Vertical splits
  self.hSplit = config and config.hSplit or 1 -- Horizontal splits

  -- Spacing around each sprite in the sheet
  -- For when gaps exist between sprites
  self.spacing = config and config.spacing or {top = 0, bottom = 0, left = 0, right = 0}

  if texture_url then
    self:load(texture_url)
    self:generate_sprites(self.hSplit, self.vSplit) -- Default to single sprite
  else
    error("SpriteSheet requires a texture URL to load.")
  end
end

function SpriteSheet:load(texture_url)
  self.texture = love.graphics.newImage(texture_url)
end

function SpriteSheet:get_sprite(index)
  return self.sprites[index]
end

function SpriteSheet:generate_sprites(hSplit, vSplit, spacing)
  self.hSplit = hSplit
  self.vSplit = vSplit

  if spacing then
    self.spacing = spacing
  end

  local sprite_width = self.texture:getWidth() / hSplit
  local sprite_height = self.texture:getHeight() / vSplit

  for y = 0, vSplit - 1 do
    for x = 0, hSplit - 1 do
      local quad = love.graphics.newQuad(
        x * sprite_width + self.spacing.left,
        y * sprite_height + self.spacing.top,
        sprite_width - self.spacing.left - self.spacing.right,
        sprite_height - self.spacing.top - self.spacing.bottom,
        self.texture:getDimensions()
      )
      table.insert(self.sprites, quad)
    end
  end
end
