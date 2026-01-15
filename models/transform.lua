---@class Transform : Class
Transform = Class:extend()

---* A Transform represents the position, rotation, scale, and skew of an object in 2D space.
---* It is used to define how an object is placed and oriented within a scene.
---* When combined with a Rect, it can represent a rectangle in 2D space with specific transformations applied.

--- Constructor for the Transform class
--- @param ... any constructor overloads:
---   - (Transform other)
---   - (Vector2 position, number rotation)
---   - (Vector2 position, number rotation, Vector2 scale)
---   - (Vector2 position, number rotation, Vector2 scale, Vector2 skew)
---   - (Vector2 position, number rotation, Vector2 scale, Vector2 skew, Vector2 pivot)
function Transform:init(...)
  local args = {...}
  local data

  -- Constructor from another Transform
  if #args == 1 and args[1]:is(Transform) then
    data = self:from_transform(args[1])

  -- Constructor from position and rotation
  elseif #args == 2 and
          args[1]:is(Vector2) and
          type(args[2]) == "number" then
    data = self:from_pos_rot(args[1], args[2])

  -- Constructor from position, rotation, and scale
  elseif #args == 3 and
          args[1]:is(Vector2) and
          type(args[2]) == "number" and
          args[3]:is(Vector2) then
    data = self:from_pos_rot_scale(args[1], args[2], args[3])

  -- Constructor from position, rotation, scale, and skew
  elseif #args == 4 and
          args[1]:is(Vector2) and
          type(args[2]) == "number" and
          args[3]:is(Vector2) and
          args[4]:is(Vector2) then
    data = self:from_pos_rot_scale_skew(args[1], args[2], args[3], args[4])

  -- Constructor from position, rotation, scale, skew, and pivot
  elseif #args == 5 and
          args[1]:is(Vector2) and
          type(args[2]) == "number" and
          args[3]:is(Vector2) and
          args[4]:is(Vector2) and
          args[5]:is(Vector2) then
    data = self:from_pos_rot_scale_skew_pivot(args[1], args[2], args[3], args[4], args[5])
  elseif #args == 0 then
    -- Default constructor (position (0,0), rotation 0, scale (1,1), skew (0,0), pivot (0,0))
    data = self:from_pos_rot_scale_skew_pivot(Vector2(0, 0), 0, Vector2(1, 1), Vector2(0, 0), Vector2(0, 0))
  else
    error("Invalid arguments to Transform constructor: " .. table.concat(
      vim.tbl_map(function(v) return type(v) end, args), ", "))
  end


  -- Apply data
  self.position = data.position
  self.rotation = data.rotation
  self.scale = data.scale
  self.skew = data.skew

  -- Pivot is an offset Vector2 which acts as the origin for rotation, scaling, and skewing
  self.pivot = data.pivot
end


-- ------------------------------ CONSTRUCTORS ------------------------------ --

--- Creates a Transform as a copy of another Transform.
--- @param other Transform The Transform to copy.
--- @return table
function Transform:from_transform(other)
  return {
    position = other.position:clone(),
    rotation = other.rotation,
    scale = other.scale:clone(),
    skew = other.skew:clone(),
    pivot = other.pivot:clone()
  }
end

--- Creates a Transform from position and rotation.
--- @param position Vector2 The position of the Transform.
--- @param rotation number The rotation of the Transform in radians.
--- @return table
function Transform:from_pos_rot(position, rotation)
  return {
    position = position:clone(),
    rotation = rotation,
    scale = Vector2(1, 1),
    skew = Vector2(0, 0),
    pivot = Vector2(0, 0)
  }
end

--- Creates a Transform from position, rotation, and scale.
--- @param position Vector2 The position of the Transform.
--- @param rotation number The rotation of the Transform in radians.
--- @param scale Vector2 The scale of the Transform.
--- @return table
function Transform:from_pos_rot_scale(position, rotation, scale)
  return {
    position = position:clone(),
    rotation = rotation,
    scale = scale:clone(),
    skew = Vector2(0, 0),
    pivot = Vector2(0, 0)
  }
end

--- Creates a Transform from position, rotation, scale, and skew.
--- @param position Vector2 The position of the Transform.
--- @param rotation number The rotation of the Transform in radians.
--- @param scale Vector2 The scale of the Transform.
--- @param skew Vector2 The skew of the Transform.
--- @return table
function Transform:from_pos_rot_scale_skew(position, rotation, scale, skew)
  return {
    position = position:clone(),
    rotation = rotation,
    scale = scale:clone(),
    skew = skew:clone(),
    pivot = Vector2(0, 0)
  }
end

--- Creates a Transform from position, rotation, scale, skew, and pivot.
--- @param position Vector2 The position of the Transform.
--- @param rotation number The rotation of the Transform in radians.
--- @param scale Vector2 The scale of the Transform.
--- @param skew Vector2 The skew of the Transform.
--- @param pivot Vector2 The pivot of the Transform.
--- @return table
function Transform:from_pos_rot_scale_skew_pivot(position, rotation, scale, skew, pivot)
  return {
    position = position:clone(),
    rotation = rotation,
    scale = scale:clone(),
    skew = skew:clone(),
    pivot = pivot:clone()
  }
end

-- ----------------------------- SPECIAL METHODS ---------------------------- --

function Transform:__tostring()
  return string.format(
    "Transform(Position: %s, Rotation: %.2f rad (%.2f deg), Scale: %s, Skew: %s)",
    tostring(self.position),
    self.rotation,
    self.rotation_degrees,
    tostring(self.scale),
    tostring(self.skew)
  )
end

function Transform:__eq(other)
  return self.position == other.position and
         self.rotation == other.rotation and
         self.scale == other.scale and
         self.skew == other.skew and
         self.pivot == other.pivot
end
