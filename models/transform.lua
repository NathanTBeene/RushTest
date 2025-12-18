---@class Transform
Transform = Class:extend()

--- Constructor for the Transform class
--- @param x number
function Transform:new(x, y, z, width, height, rotation_x, rotation_y, scale_x, scale_y)
    self.position = Vector2(x or 0, y or 0)
    self.rotation = Vector2(rotation_x or 0, rotation_y or 0)
    self.scale = Vector2(scale_x or 1, scale_y or 1)
    self.z = z or 0
    self.width = width or 1
    self.height = height or 1
end
