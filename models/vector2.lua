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

function Vector2:__add(other)
    return Vector2(self.x + other.x, self.y + other.y)
end

function Vector2:__sub(other)
    return Vector2(self.x - other.x, self.y - other.y)
end

function Vector2:__mul(other)
    if type(other) == "number" then
        return Vector2(self.x * other, self.y * other)
    else
        return Vector2(self.x * other.x, self.y * other.y)
    end
end

function Vector2:__div(other)
    if type(other) == "number" then
        return Vector2(self.x / other, self.y / other)
    else
        return Vector2(self.x / other.x, self.y / other.y)
    end
end

function Vector2:__unm()
    return Vector2(-self.x, -self.y)
end

function Vector2:__eq(other)
    return self.x == other.x and self.y == other.y
end

-- --------------------------- PREDEFINED VECTORS --------------------------- --
Vector2.ZERO = Vector2(0, 0)
Vector2.ONE = Vector2(1, 1)
Vector2.UP = Vector2(0, -1)
Vector2.DOWN = Vector2(0, 1)
Vector2.LEFT = Vector2(-1, 0)
Vector2.RIGHT = Vector2(1, 0)
