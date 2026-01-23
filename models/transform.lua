---@class Transform : Class
Transform = Class:extend("Transform")

local PropertyMixin = require("engine.mixins.property")
Transform:implement(PropertyMixin)

local ConstructorMixin = require("engine.mixins.constructor")
Transform:implement(ConstructorMixin)

---* A Transform represents the position, rotation, scale, and skew of an object in 2D space.
---* It is used to define how an object is placed and oriented within a scene.
---* When combined with a Rect, it can represent a rectangle in 2D space with specific transformations applied.

Transform:define_property("position",
  function(t) return t._position end,
  function(t, value)
    value:is(Vector2)
    t._position = value
  end
)

Transform:define_property("rotation",
  function(t) return t._rotation end,
  function(t, value)
    assert(type(value) == "number", "Rotation must be a number (in radians).")
    t._rotation = value
  end
)

Transform:define_property("scale",
  function(t) return t._scale end,
  function(t, value)
    value:is(Vector2)
    t._scale = value
  end
)

Transform:define_property("skew",
  function(t) return t._skew end,
  function(t, value)
    value:is(Vector2)
    t._skew = value
  end
)

Transform:define_property("pivot",
  function(t) return t._pivot end,
  function(t, value)
    value:is(Vector2)
    t._pivot = value
  end
)

-- Rotation in degrees (convenience property)
-- Completely calculated and not stored
Transform:define_property("rotation_degrees",
  function(t)
    return math.deg(t.rotation)
  end,
  function(t, value)
    assert(type(value) == "number", "Rotation must be a number (in degrees).")
    t.rotation = math.rad(value)
  end,
  {proxy = false} -- Not stored, so no proxying
)

Transform:_constructors({
  -- Default Constructor
  {
    matcher = function(args)
      return #args == 0
    end,
    builder = function(self, args)
      self:init_properties()

      self._position = Vector2(0, 0)
      self._rotation = 0
      self._scale = Vector2(1, 1)
      self._skew = Vector2(0, 0)
      self._pivot = Vector2(0, 0)
    end
  },

  -- Copy Constructor : Transform(other_transform)
  {
    matcher = function(args)
      return #args == 1 and args[1]:is(Transform)
    end,
    builder = function(self, args)
      self:init_properties()

      local other = args[1]
      self._position = other.position:clone()
      self._rotation = other.rotation
      self._scale = other.scale:clone()
      self._skew = other.skew:clone()
      self._pivot = other.pivot:clone()
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
      self:init_properties()

      self._position = args[1]:clone()
      self._rotation = args[2]
      self._scale = Vector2(1, 1)
      self._skew = Vector2(0, 0)
      self._pivot = Vector2(0, 0)
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
      self:init_properties()

      self._position = args[1]:clone()
      self._rotation = args[2]
      self._scale = args[3]:clone()
      self._skew = Vector2(0, 0)
      self._pivot = Vector2(0, 0)
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
      self:init_properties()

      self._position = args[1]:clone()
      self._rotation = args[2]
      self._scale = args[3]:clone()
      self._skew = args[4]:clone()
      self._pivot = Vector2(0, 0)
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
      self:init_properties()

      self._position = args[1]:clone()
      self._rotation = args[2]
      self._scale = args[3]:clone()
      self._skew = args[4]:clone()
      self._pivot = args[5]:clone()
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
