---@class Rect : Class
Rect = Class:extend("Rect")

---*  A Rect is a simple rectangle shape defined by its position and size.
---* When combined with a Transform, it can represent a rectangle in 2D space.

--- Constructor for the Rect class
--- @param ... any constructor overloads:
---   - (Vector2 position, Vector2 size)
---   - (number x, number y, number width, number height)
---   - (Rect rect)
function Rect:init(...)
  local args = {...}
  local data

  -- Constructor from two Vector2s
  if #args == 2 and args[1]:is(Vector2) and args[2]:is(Vector2) then
    data = self:_from_vectors(args[1], args[2])
  end
  -- Constructor from individual dimensions
  if #args == 4 and
     type(args[1]) == "number" and
     type(args[2]) == "number" and
     type(args[3]) == "number" and
     type(args[4]) == "number" then
    data = self:_from_dimensions(args[1], args[2], args[3], args[4])
  end
  -- Constructor from another Rect
  if #args == 1 and args[1]:is(Rect) then
    data = self:_from_rect(args[1])
  end
  -- Default constructor (0,0) position and (0,0) size
  if not data then
    data = self:_from_dimensions(0, 0, 0, 0)
  end

  -- Apply data
  self.position = data.position
  self.size = data.size
end

-- ------------------------------ CONSTRUCTORS ------------------------------ --

--- Creates a Rect from individual dimensions.
--- @param x number The x-coordinate of the rectangle's top-left corner.
--- @param y number The y-coordinate of the rectangle's top-left corner.
--- @param width number The width of the rectangle.
--- @param height number The height of the rectangle.
function Rect:_from_dimensions(x, y, width, height)
  return {position = Vector2(x, y), size = Vector2(width, height)}
end

--- Creates a Rect from two Vector2s.
--- @param position Vector2 The position of the rectangle's top-left corner.
--- @param size Vector2 The size of the rectangle.
function Rect:_from_vectors(position, size)
  return {position = position, size = size}
end

--- Creates a Rect as a copy of another Rect.
--- @param rect Rect The Rect to copy.
function Rect:_from_rect(rect)
  return {position = rect.position:clone(), size = rect.size:clone()}
end


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
--- @return table A table containing the four corners of the rectangle.
function Rect:get_bounds()
  return {
    Vector2(self.position.x, self.position.y), -- Top-left
    Vector2(self.position.x + self.size.x, self.position.y), -- Top-right
    Vector2(self.position.x + self.size.x, self.position.y + self.size.y), -- Bottom-right
    Vector2(self.position.x, self.position.y + self.size.y) -- Bottom-left
  }
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
