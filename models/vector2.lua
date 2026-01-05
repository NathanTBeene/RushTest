---@class Vector2
Vector2 = Class:extend()

function Vector2:init(x, y)
    self.x = x or 0
    self.y = y or 0
end


function Vector2:__tostring()
    return string.format("Vector2(%.2f, %.2f)", self.x, self.y)
end
