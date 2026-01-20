---@class Rect : Class
Rect = Class:extend("Rect")

local ConstructorMixin = require("engine.mixins.constructor")
Rect:implement(ConstructorMixin)

---*  A Rect is a simple rectangle shape defined by its position and size.
---* When combined with a Transform, it can represent a rectangle in 2D space.

Rect:_constructors({
  -- Default Constructor
  {
    matcher = function(args)
      return #args == 0
    end,
    builder = function(self, args)
      self.position = Vector2(0, 0)
      self.size = Vector2(0, 0)
    end
  },

  -- Copy Constructor : Rect(other_rect)
  {
    matcher = function(args)
      return #args == 1 and args[1]:is(Rect)
    end,
    builder = function(self, args)
      local other = args[1]
      self.position = Vector2(other.position.x, other.position.y)
      self.size = Vector2(other.size.x, other.size.y)
    end
  },

  -- Rect(x, y, width, height)
  {
    matcher = function(args)
      return #args == 4 and
             type(args[1]) == "number" and
             type(args[2]) == "number" and
             type(args[3]) == "number" and
             type(args[4]) == "number"
    end,
    builder = function(self, args)
      self.position = Vector2(args[1], args[2])
      self.size = Vector2(args[3], args[4])
    end
  },

  -- Rect(position, size)
  {
    matcher = function(args)
      return #args == 2 and
             args[1]:is(Vector2) and
             args[2]:is(Vector2)
    end,
    builder = function(self, args)
      self.position = args[1]
      self.size = args[2]
    end
  },
})

-- --------------------------------- GETTERS -------------------------------- --

--- Calculates and returns the area of the rectangle.
--- @return number The area of the rectangle.
function Rect:get_area()
  return self.size.x * self.size.y
end

--- Calculates and returns the center point of the rectangle.
--- @return Vector2 The center point of the rectangle.
function Rect:get_center()
  return Vector2(
    self.position.x + self.size.x / 2,
    self.position.y + self.size.y / 2
  )
end

--- Expands the rectangle by increasing its size.
--- Negative values will shrink the rectangle.
--- @param amount number The amount to grow the rectangle by on all sides.
function Rect:grow(amount)
  self.position.x = self.position.x - amount
  self.position.y = self.position.y - amount
  self.size.x = self.size.x + (amount * 2)
  self.size.y = self.size.y + (amount * 2)
end

--- Expands the rectangle by increasing its size individually on each side.
--- Negative values will shrink the rectangle.
--- @param left number The amount to grow the rectangle on the left side.
--- @param top number The amount to grow the rectangle on the top side.
--- @param right number The amount to grow the rectangle on the right side.
--- @param bottom number The amount to grow the rectangle on the bottom side.
function Rect:grow_individual(left, top, right, bottom)
  self.position.x = self.position.x - left
  self.position.y = self.position.y - top
  self.size.x = self.size.x + left + right
  self.size.y = self.size.y + top + bottom
end

--- Returns the four corners of the rectangle as a table of Vector2 points.
--- @return Rect A copy Rect representing the four corners of the rectangle.
function Rect:get_bounds()
  return Rect(
    self.position.x,
    self.position.y,
    self.size.x,
    self.size.y
  )
end

--- Calculates the intersection of this rectangle with another rectangle.
--- If no intersection exists, returns empty Rect.
--- @param other Rect The other rectangle to intersect with.
--- @return Rect The intersecting rectangle, or an empty Rect if no intersection exists.
function Rect:intersection(other)
  local x1 = math.max(self.position.x, other.position.x)
  local y1 = math.max(self.position.y, other.position.y)
  local x2 = math.min(self.position.x + self.size.x, other.position.x + other.size.x)
  local y2 = math.min(self.position.y + self.size.y, other.position.y + other.size.y)

  if x2 >= x1 and y2 >= y1 then
    return Rect(x1, y1, x2 - x1, y2 - y1)
  else
    return Rect(0, 0, 0, 0) -- No intersection
  end
end

-- -------------------------------- CHECKERS -------------------------------- --

--- Returns true if the rectangle has a positive area.
--- @return boolean True if the rectangle is valid (positive area), false otherwise.
function Rect:has_area()
  return self.size.x > 0 and self.size.y > 0
end

--- Checks if a given point is inside the rectangle.
--- @param point Vector2 The point to check.
--- @return boolean True if the point is inside the rectangle, false otherwise.
function Rect:has_point(point)
  return point.x >= self.position.x and
         point.x <= self.position.x + self.size.x and
         point.y >= self.position.y and
         point.y <= self.position.y + self.size.y
end

--- Checks if this rectangle intersects with another rectangle.
--- @param other Rect The other rectangle to check against.
--- @return boolean True if the rectangles intersect, false otherwise.
function Rect:intersects(other)
  return not (
    self.position.x + self.size.x < other.position.x or
    self.position.x > other.position.x + other.size.x or
    self.position.y + self.size.y < other.position.y or
    self.position.y > other.position.y + other.size.y
  )
end
-- ----------------------------- SPECIAL METHODS ---------------------------- --

function Rect:__tostring()
  return string.format(
    "Rect(Position: %s, Size: %s)",
    tostring(self.position),
    tostring(self.size)
  )
end

function Rect:__eq(other)
  return self.position == other.position and
         self.size == other.size
end
