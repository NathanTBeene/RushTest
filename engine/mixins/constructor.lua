---@class ConstructorMixin

local ConstructorMixin = {}

--- Registers constructor patterns for a class.
--- @param patterns table[] A list of constructor patterns, each containing:
--- @matcher function | A function that takes arguments and returns true if they match the pattern.
--- @builder function | A function that takes the object and arguments to build the instance.
function ConstructorMixin:_constructors(patterns)
  self._constructor_patterns = patterns
  self._original_init = self.init

  self.init = function(obj, ...)
    local args = {...}

    -- Try each registered pattern
    for _, pattern in ipairs(self._constructor_patterns) do
      if pattern.matcher(args) then
        pattern.builder(obj, args)
        return
      end
    end

    -- Fallback to original init if no pattern matched
    if self._original_init then
      self._original_init(obj, ...)
    else
      error("No matching constructor pattern found and no original init defined.")
    end
  end
end

return ConstructorMixin
