--||--
--This Object implementation was taken from SNKRX (MIT license). Slightly modified, this is a very simple OOP base

Class = {}
Class.__index = Class
function Class:init()
end

function Class:extend()
  local cls = {}
  for k, v in pairs(self) do
    if k:find("__") == 1 then
      cls[k] = v
    end
  end
  cls.__index = cls
  cls.super = self
  setmetatable(cls, self)
  return cls
end

function Class:is(T)
  local mt = getmetatable(self)
  while mt do
    if mt == T then
      return true
    end
    mt = getmetatable(mt)
  end
  return false
end

function Class:__call(...)
  local obj = setmetatable({}, self)
  obj:init(...)
  return obj
end

function Class:__to_string()
  return self.__name or "Class"
end

function Class:__concat(other)
  return self:__to_string() .. other
end

function Class:get_parent()
  return self.super
end
