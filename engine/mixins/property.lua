---@class PropertyMixin

local PropertyMixin = {}

local Proxy = require("engine.mixins.proxy")

function PropertyMixin:init_properties()
  self.__properties = self.__properties or {}
  self.__property_values = self.__property_values or {}

  -- Setup metatable to intercept property access
  local original_mt = getmetatable(self)
  local original_index = original_mt.__index
  local original_newindex = original_mt.__newindex

  local property_mt = {
    __index = function(t, k)
      -- Check if it's a property with a getter
      if rawget(t, "__properties") and rawget(t, "__properties")[k] then
        local prop = rawget(t, "__properties")[k]
        local getter = prop.get

        if getter then
          local value = getter(t)
          -- Check if we should wrap in proxy
          -- By default, wrap tables unless explicitly disables with {proxy = false}
          local should_proxy = prop.proxy
          if should_proxy == nil then
            should_proxy = type(value) == "table"
          end

          if should_proxy then
            return Proxy.create_proxy(value, t, k)
          end
          return value
        end

        -- No getter, use stored value
        local value = rawget(t, "__property_values")[k]

        -- Also proxy stored values if they are tables
        local should_proxy = prop.proxy
        if should_proxy == nil then
          should_proxy = type(value) == "table"
        end

        if should_proxy and type(value) == "table" then
          return Proxy.create_proxy(value, t, k)
        end
        return value
      end

      -- Fallback to original __index (call as function if it's a function)
      if type(original_index) == "function" then
        return original_index(t, k)
      elseif type(original_index) == "table" then
        return original_index[k]
      end
    end,

    __newindex = function(t, k, v)
      -- Check if it's a property with a setter
      if rawget(t, "__properties") and rawget(t, "__properties")[k] then
        local setter = rawget(t, "__properties")[k].set
        if setter then
          setter(t, v)
          return
        end
        rawget(t, "__property_values")[k] = v
        return
      end

      -- Fallback to original __newindex or rawset
      if original_newindex then
        original_newindex(t, k, v)
      else
        rawset(t, k, v)
      end
    end
  }

  -- Preserve other metamethods
  for k, v in pairs(original_mt) do
    if k ~= "__index" and k ~= "__newindex" then
      property_mt[k] = v
    end
  end

  setmetatable(self, property_mt)
end

--- Defines a property with optional getter and setter
--- @param name string The property name
--- @param getter? function Function to get the property value
--- @param setter? function Function to set the property value
--- @param options? table Additional options (e.g., {proxy = false} to disable proxying)
function PropertyMixin:define_property(name, getter, setter, options)
  self.__properties = self.__properties or {}
  options = options or {}
  self.__properties[name] = {
    get = getter,
    set = setter,
    proxy = options.proxy
  }
end


return PropertyMixin
