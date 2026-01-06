---@class Vector2 : Class
Vector2 = Class:extend()

--- Constructor
--- @param x number
--- @param y number
function Vector2:init(x, y)
    self.x = x or 0
    self.y = y or 0
end

-- ----------------------------- SPECIAL METHODS ---------------------------- --

function Vector2:__tostring()
    return string.format("Vector2(%.2f, %.2f)", self.x, self.y)
end
