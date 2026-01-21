---@diagnostic disable: undefined-doc-name
--||--
--The base Object implementation was taken from SNKRX (MIT license) and then heavily modified and extended for this engine.
--||--

--- @class Class
Class = {}
Class.__index = Class
function Class:init()
end

--- Creates a subclass of the current class
--- @return Class
function Class:extend(name)
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.__name = name or self.__name or "UnnamedClass"
  cls.name = cls.__name
  cls.super = self
  setmetatable(cls, self)
  return cls
end

-- ------------------------------ COPY METHODS ------------------------------ --

--- Creates a shallow copy of the current instance
--- @return Class
function Class:clone()
  local copy = setmetatable({}, getmetatable(self))
  for k, v in pairs(self) do
    copy[k] = v
  end
  return copy
end

--- Creates a deep copy of the current instance
--- @return Class
function Class:deep_clone()
  local function deep_copy(obj)
    if type(obj) ~= "table" then return obj end

    local copy = setmetatable({}, getmetatable(obj))
    for k, v in pairs(obj) do
      copy[k] = deep_copy(v)
    end
    return copy
  end

  return deep_copy(self)
end

-- -------------------------------- CHECKERS -------------------------------- --

--- Checks if the current class is a subclass of T or T itself
--- @param T Class
--- @return boolean
function Class:includes(T)
  local mt = self
  while mt do
    if mt == T then return true end
    mt = mt.super
  end
  return false
end

--- Checks if the current instance is of type T or a subclass thereof
--- @param T Class
--- @return boolean
function Class:is(T)
  -- Handle primitives (numbers, strings, etc.) that don't have class metatables
  if type(self) ~= "table" then
    return false
  end

  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end

-- --------------------------------- MIXINS --------------------------------- --

--- Implements mixins into the current class
--- @param ... table Mixins to implement
function Class:implement(...)
  for _, mixin in pairs({...}) do
    for k, v in pairs(mixin) do
      if self[k] == nil then -- Only add if not already present
        self[k] = v
      end
    end
  end
end

-- ----------------------------- SPECIAL METHODS ---------------------------- --

--- Creates a new instance of the class
--- @return Class
function Class:__call(...)
  local args = {...}
  local obj = setmetatable({}, self)
  -- Pass down name and __name from class to instance
  obj.name = self.name
  obj.__name = self.__name
  obj:init(unpack(args))
  return obj
end

--- Returns a string representation of the class
--- @return string
function Class:__tostring()
  local str
  if self.name ~= self.__name then
    str = string.format("<%s:%s>", self.__name, tostring(self.name))
  else
    str = string.format("<%s>", self.__name)
  end
  return str
end

--- Concatenates the string representation of the class with another string
--- @param other string
function Class:__concat(other)
  return self:__tostring() .. other
end

--- Gets the parent class of the current class
--- @return Class
function Class:get_parent()
  return self.super
end

function Class:_print_metatable()
  local mt = getmetatable(self)
  print("Metatable of " .. tostring(self) .. ":")
  for k, v in pairs(mt) do
    print("  " .. tostring(k) .. " : " .. tostring(v))
  end
end
