---@class Style : Class
Style = Class:extend("Style")

local PropertyMixin = require("engine.mixins.property")
Style:implement(PropertyMixin)

---* Style defines the visual appearance of UI components.
---* It includes properties for different states like normal, hovered, pressed, and disabled.
---* Each state can have its own set of style attributes such as colors, fonts, and sizes.

function Style:init(config)
  self.states = {
    normal = {
      backgroundColor = Color.white,
      borderColor = Color.black,
      borderWidth = 2,
      borderRadius = 4,
      textColor = Color.black,
      font = love.graphics.newFont(14),
      fontSize = 14,
      padding = {
        top = 8,
        right = 12,
        bottom = 8,
        left = 12
      },
      margin = {
        top = 4,
        right = 4,
        bottom = 4,
        left = 4
      },
      opacity = 1.0,
      cursor = Cursor.ARROW,
      --TODO: Implement transitions
      transition = {
        duration = 0.2,
        easing = "linear"
      },
      -- TODO: Implement shadow rendering
      shadow = {
        offsetX = 2,
        offsetY = 2,
        blur = 4,
        color = Color(0, 0, 0, 5)
      }
    },
    hovered = {
      backgroundColor = Color(230, 230, 230),
      borderColor = Color(60, 120, 220),
      borderWidth = 2,
      borderRadius = 4,
      textColor = Color.black,
      font = love.graphics.newFont(14),
      fontSize = 14,
      padding = {
        top = 8,
        right = 12,
        bottom = 8,
        left = 12
      },
      margin = {
        top = 4,
        right = 4,
        bottom = 4,
        left = 4
      },
      opacity = 1.0,
      cursor = Cursor.HAND,
      transition = {
        duration = 0.15,
        easing = "ease-in-out"
      },
      shadow = {
        offsetX = 2,
        offsetY = 2,
        blur = 4,
        color = Color(0, 0, 0, 8)
      }
    },
    pressed = {
      backgroundColor = Color(200, 200, 200),
      borderColor = Color(40, 80, 160),
      borderWidth = 2,
      borderRadius = 4,
      textColor = Color.black,
      font = love.graphics.newFont(14),
      fontSize = 14,
      padding = {
        top = 8,
        right = 12,
        bottom = 8,
        left = 12
      },
      margin = {
        top = 4,
        right = 4,
        bottom = 4,
        left = 4
      },
      opacity = 0.95,
      cursor = Cursor.HAND,
      transition = {
        duration = 0.1,
        easing = "ease-in"
      },
      shadow = {
        offsetX = 1,
        offsetY = 1,
        blur = 2,
        color = Color(0, 0, 0, 10)
      }
    },
    disabled = {
      backgroundColor = Color(240, 240, 240),
      borderColor = Color(180, 180, 180),
      borderWidth = 2,
      borderRadius = 4,
      textColor = Color(160, 160, 160),
      font = love.graphics.newFont(14),
      fontSize = 14,
      padding = {
        top = 8,
        right = 12,
        bottom = 8,
        left = 12
      },
      margin = {
        top = 4,
        right = 4,
        bottom = 4,
        left = 4
      },
      opacity = 0.6,
      cursor = Cursor.NOT_ALLOWED,
      transition = {
        duration = 0.2,
        easing = "linear"
      },
      shadow = {
        offsetX = 0,
        offsetY = 0,
        blur = 0,
        color = Color(0, 0, 0, 0)
      }
    }
  }

  self:init_properties()

  self:define_property("normal",
  function(self)
    return self.states.normal
  end)

  self:define_property("hovered",
  function(self)
    return self.states.hovered
  end)

  self:define_property("pressed",
  function(self)
    return self.states.pressed
  end)

  -- Merge user config if provided
  -- Only use already defined properties
  if config then
    for state_name, state_values in pairs(config) do
      if self.states[state_name] then
        for key, value in pairs(state_values) do
          if self.states[state_name][key] ~= nil then
            self.states[state_name][key] = value
          else
            Conduit.system:warn("Style property '" .. key .. "' is not defined for state '" .. state_name .. "'.")
          end
        end
      else
        Conduit.system:warn("Style state '" .. state_name .. "' is not defined.")
      end
    end
  end
end

-- ---------------------------- PREDEFINED STYLES --------------------------- --

Style.BUTTON = Style({

})  -- Default button style instance
