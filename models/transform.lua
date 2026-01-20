---@class Transform : Class
Transform = Class:extend("Transform")

local ConstructorMixin = require("engine.mixins.constructor")
Transform:implement(ConstructorMixin)

---* A Transform represents the position, rotation, scale, and skew of an object in 2D space.
---* It is used to define how an object is placed and oriented within a scene.
---* When combined with a Rect, it can represent a rectangle in 2D space with specific transformations applied.

Transform:_constructors({
  -- Default Constructor
  {
    matcher = function(args)
      return #args == 0
    end,
    builder = function(self, args)
      self.position = Vector2(0, 0)
      self.rotation = 0
      self.scale = Vector2(1, 1)
      self.skew = Vector2(0, 0)
      self.pivot = Vector2(0, 0)
    end
  },

  -- Copy Constructor : Transform(other_transform)
  {
    matcher = function(args)
      return #args == 1 and args[1]:is(Transform)
    end,
    builder = function(self, args)
      local other = args[1]
      self.position = other.position:clone()
      self.rotation = other.rotation
      self.scale = other.scale:clone()
      self.skew = other.skew:clone()
      self.pivot = other.pivot:clone()
    end
  },

  -- Transform(position, rotation)
  {
    matcher = function(args)
      return #args == 2 and
             args[1]:is(Vector2) and
             type(args[2]) == "number"
    end,
    builder = function(self, args)
      self.position = args[1]:clone()
      self.rotation = args[2]
      self.scale = Vector2(1, 1)
      self.skew = Vector2(0, 0)
      self.pivot = Vector2(0, 0)
    end
  },

  -- Transform(position, rotation, scale)
  {
    matcher = function(args)
      return #args == 3 and
             args[1]:is(Vector2) and
             type(args[2]) == "number" and
             args[3]:is(Vector2)
    end,
    builder = function(self, args)
      self.position = args[1]:clone()
      self.rotation = args[2]
      self.scale = args[3]:clone()
      self.skew = Vector2(0, 0)
      self.pivot = Vector2(0, 0)
    end
  },

  -- Transform(position, rotation, scale, skew)
  {
    matcher = function(args)
      return #args == 4 and
             args[1]:is(Vector2) and
             type(args[2]) == "number" and
             args[3]:is(Vector2) and
             args[4]:is(Vector2)
    end,
    builder = function(self, args)
      self.position = args[1]:clone()
      self.rotation = args[2]
      self.scale = args[3]:clone()
      self.skew = args[4]:clone()
      self.pivot = Vector2(0, 0)
    end
  },

  -- Transform(position, rotation, scale, skew, pivot)
  {
    matcher = function(args)
      return #args == 5 and
             args[1]:is(Vector2) and
             type(args[2]) == "number" and
             args[3]:is(Vector2) and
             args[4]:is(Vector2) and
             args[5]:is(Vector2)
    end,
    builder = function(self, args)
      self.position = args[1]:clone()
      self.rotation = args[2]
      self.scale = args[3]:clone()
      self.skew = args[4]:clone()
      self.pivot = args[5]:clone()
    end
  }
})

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
