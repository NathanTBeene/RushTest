---@class Proxy

local Proxy = {}

Proxy.__index = function(t, k)
  local wrapped = rawget(t, "__wrapped")
  return wrapped[k]
end

Proxy.__newindex = function(t, k, v)
  local wrapped = rawget(t, "__wrapped")
  local parent = rawget(t, "__parent")
  local property_name = rawget(t, "__property_name")

  -- Update the wrapped object first
  wrapped[k] = v

  if parent and property_name then
    -- Try to get __properties from instance first, then from metatable (class)
    local props = rawget(parent, "__properties")
    if not props then
      local mt = getmetatable(parent)
      if mt then
        props = rawget(mt, "__properties")
      end
    end

    if props and props[property_name] then
      local setter = props[property_name].set
      if setter then
        -- Call the setter with the modified wrapped object
        setter(parent, wrapped)
      else
        -- No setter, store in property values
        local prop_values = rawget(parent, "__property_values")
        if prop_values then
          prop_values[property_name] = wrapped
        end
      end
    end
  end
end

Proxy.__add = function(t, other) return rawget(t, "__wrapped") + other end
Proxy.__sub = function(t, other) return rawget(t, "__wrapped") - other end
Proxy.__mul = function(t, other) return rawget(t, "__wrapped") * other end
Proxy.__div = function(t, other) return rawget(t, "__wrapped") / other end
Proxy.__unm = function(t) return -rawget(t, "__wrapped") end
Proxy.__eq = function(t, other)
  local wrapped = rawget(t, "__wrapped")
  local other_wrapped = type(other) == "table" and rawget(other, "__wrapped")
  return wrapped == (other_wrapped or other)
end
Proxy.__tostring = function(t) return tostring(rawget(t, "__wrapped")) end
Proxy.__concat = function(a, b)
  local a_val = type(a) == "table" and rawget(a, "__wrapped") or a
  local b_val = type(b) == "table" and rawget(b, "__wrapped") or b
  return tostring(a_val) .. tostring(b_val)
end

--- Unwraps a proxy to get the underlying value
--- @param value any The value to unwrap
--- @return any The unwrapped value, or the original value if not a proxy
function Proxy.unwrap(value)
  if type(value) == "table" and rawget(value, "__wrapped") then
    return rawget(value, "__wrapped")
  end
  return value
end

--- Creates a proxy wrapper around an object
--- @param obj any The object to wrap
--- @param parent table The parent object that owns this property
--- @param property_name string The name of the property on the parent
--- @return table The proxy wrapper, or the original object if it's not a table
function Proxy.create_proxy(obj, parent, property_name)
  -- Unwrap if already proxied
  obj = Proxy.unwrap(obj)

  -- Only proxy tables
  if type(obj) ~= "table" then
    return obj
  end

  local proxy = {
    __wrapped = obj,
    __parent = parent,
    __property_name = property_name,
  }
  setmetatable(proxy, Proxy)
  return proxy
end

return Proxy
