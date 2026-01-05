---@class Transform
Transform = Class:extend()

--- Constructor for the Transform class
--- @param x number
--- @param y number
--- @param z number
--- @param width number
--- @param height number
--- @param rotation_x number
--- @param rotation_y number
--- @param scale_x number
--- @param scale_y number
function Transform:init(x, y, z, width, height, rotation_x, rotation_y, scale_x, scale_y)
    self.position = Vector2(x or 0, y or 0)
    self.rotation = Vector2(rotation_x or 0, rotation_y or 0)
    self.scale = Vector2(scale_x or 1, scale_y or 1)
    self.z = z or 0
    self.width = width or 1
    self.height = height or 1
    self.pivot = Vector2(0, 0)
end


function Transform:__tostring()
    return string.format("Transform(position: %s, rotation: %s, scale: %s, z: %d, width: %d, height: %d)",
        tostring(self.position), tostring(self.rotation), tostring(self.scale), self.z, self.width, self.height)
end
