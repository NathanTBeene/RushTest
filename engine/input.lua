---@class Input : Class
Input = Class:extend("Input")

function Input:init()
  self.debug = G.debug or false
  self.log_keys = false -- Set to true to log all key events

  -- Current frame key states
  self.keys_down = {}
  self.keys_pressed = {}
  self.keys_released = {}

  -- Mouse Button states
  self.mouse_buttons_down = {}
  self.mouse_buttons_pressed = {}
  self.mouse_buttons_released = {}

  -- Mouse position
  self.mouse_pos = Vector2(0, 0)
  self.mouse_delta = Vector2(0, 0)

  -- Action Mappings: action_name -> {keyboard = {}, mouse = {}, gamepad = {}}
  self.action_map = {}

  -- Input Layers for handling UI vs Game input
  self.layers = {}
  self.current_layer = "default"

  -- Input buffer for frame-perfect input (in seconds)
  self.buffer_time = 0.1
  self.buffered_actions = {}

  -- Conduit logging
  if Conduit then
    Conduit:console("input")
    Conduit.input:success("Input system initialized.")

    -- Mouse Watchables
    Conduit.input:group("Mouse", 1)
    Conduit.input:watch("Position", function() return tostring(self.mouse_pos) end, "Mouse", 1)
    Conduit.input:watch("Delta", function() return tostring(self.mouse_delta) end, "Mouse", 2)

    -- Action Map Watchables
    Conduit.input:group("Actions", 2)
    Conduit.input:watch("Defined Actions", function()
      local count = 0
      for _ in pairs(self.action_map) do
        count = count + 1
      end
      return tostring(count)
    end, "Actions", 1)

    Conduit.input:watch("Actions", function()
      local actions = {}
      for action_name, bindings in pairs(self.action_map) do
        local string = ""
        local state = ""
        if self:is_action_pressed(action_name) then
          state = "[ PRESSED  ]"
        elseif self:is_action_just_released(action_name) then
          state = "[ RELEASED ]"
        else
          state = "[          ]"
        end
        string = string .. action_name .. " => " .. state

        table.insert(actions, string)
      end

      return table.concat(actions, "\n")
    end, "Actions", 2)

    -- Buffered Actions Watchables
    Conduit.input:group("Buffers", 3)
    Conduit.input:watch("Buffered Actions", function()
      local keys = {}
      for k, _ in pairs(self.buffered_actions) do
        table.insert(keys, k)
      end
      return table.concat(keys, ", ")
    end, "Buffers", 1)
  end
end

-- ----------------------------- ACTION MAPPING ----------------------------- --

--- Register an action with its input bindings
--- @param action_name string The name of the action
--- @param bindings table A table containing keyboard, mouse, and gamepad bindings
function Input:add_action(action_name, bindings)
  self.action_map[action_name] = {
    keyboard = bindings.keyboard or {},
    mouse = bindings.mouse or {},
    gamepad = bindings.gamepad or {}
  }

  if Conduit and self.debug then
    Conduit.input:log("Added action '" .. action_name .. "' with bindings.")
  end
end

--- Remove an action from the action map
--- @param action_name string The name of the action to remove
function Input:remove_action(action_name)
  self.action_map[action_name] = nil

  if Conduit and self.debug then
    Conduit.input:log("Removed action '" .. action_name .. "'.")
  end
end

--- Load multiple actions from a table
--- @param actions table A table of action_name -> bindings
function Input:load_actions(actions)
  for name, bindings in pairs(actions) do
    -- Don't overwrite existing actions
    if self.action_map[name] then
      if Conduit and self.debug then
        Conduit.input:warn("Action '" .. name .. "' already exists. Skipping load.")
      end
      goto continue
    end
    self:add_action(name, bindings)
    ::continue::
  end

  if Conduit and self.debug then
    Conduit.input:log("Loaded multiple actions into action map.")
  end
end

-- ------------------------------ QUERY METHODS ----------------------------- --

--- Check if an action is currently pressed (held down)
--- @param action_name string The name of the action to check
--- @return boolean
function Input:is_action_pressed(action_name)
  local bindings = self.action_map[action_name]
  if not bindings then return false end

  -- Check keyboard bindings
  for _, key in ipairs(bindings.keyboard) do
    if self.keys_down[key] then
      return true
    end
  end

  -- Check mouse bindings
  for _, button in ipairs(bindings.mouse) do
    if self.mouse_buttons_down[button] then
      return true
    end
  end

  -- TODO: Gamepad bindings can be added here

  return false
end

--- Check if an action was just pressed this frame
--- @param action_name string The name of the action to check
--- @return boolean
function Input:is_action_just_pressed(action_name)
  local bindings = self.action_map[action_name]
  if not bindings then
    Conduit.input:warn("Action '" .. action_name .. "' not found in action map.")
    return false
  end

  -- Check keyboard bindings
  for _, key in ipairs(bindings.keyboard) do
    if self.keys_pressed[key] then
      Conduit.input:log("Action '" .. action_name .. "' triggered by key '" .. key .. "'.")
      return true
    end
  end

  -- Check mouse bindings
  for _, button in ipairs(bindings.mouse) do
    if self.mouse_buttons_pressed[button] then
      Conduit.input:log("Action '" .. action_name .. "' triggered by mouse button '" .. tostring(button) .. "'.")
      return true
    end
  end

  -- TODO: Gamepad bindings can be added here

  return false
end

--- Check if an action was just released this frame
--- @param action_name string The name of the action to check
--- @return boolean
function Input:is_action_just_released(action_name)
  local bindings = self.action_map[action_name]
  if not bindings then return false end

  -- Check keyboard bindings
  for _, key in ipairs(bindings.keyboard) do
    if self.keys_released[key] then
      return true
    end
  end

  -- Check mouse bindings
  for _, button in ipairs(bindings.mouse) do
    if self.mouse_buttons_released[button] then
      return true
    end
  end

  -- TODO: Gamepad bindings can be added here
  return false
end

--- Get the value of a virtual axis defined by two actions
--- @param negative_action string The action name for the negative direction (-1)
--- @param positive_action string The action name for the positive direction (+1)
--- @return number The axis value (-1, 0, or +1)
function Input:get_axis(negative_action, positive_action)
  local value = 0
  if self:is_action_pressed(negative_action) then
    value = value - 1
  end
  if self:is_action_pressed(positive_action) then
    value = value + 1
  end
  return value
end

--- Get a 2D vector from four actions representing left, right, up, and down
--- Game Dev staple is for y-axis to be inverted (up is -y)
--- @param left string The action name for left (-x)
--- @param right string The action name for right (+x)
--- @param up string The action name for up (-y)
--- @param down string The action name for down (+y)
--- @return Vector2 The resulting 2D vector
function Input:get_vector(left, right, up, down)
  local x = self:get_axis(left, right)
  local y = -self:get_axis(up, down)  -- Invert y-axis
  return Vector2(x, y)
end

-- ---------------------------- DIRECT KEY ACCESS --------------------------- --

--- Check if a specific key is currently pressed (held down)
--- @param key string The key to check
--- @return boolean
function Input:is_key_pressed(key)
  return self.keys_down[key] or false
end

--- Check if a specific key was just pressed this frame
--- @param key string The key to check
--- @return boolean
function Input:is_key_just_pressed(key)
  return self.keys_pressed[key] or false
end

--- Check if a specific key was just released this frame
--- @param key string The key to check
--- @return boolean
function Input:is_key_just_released(key)
  return self.keys_released[key] or false
end

-- ------------------------------ MOUSE ACCESS ------------------------------ --

--- Check if a specific mouse button is currently pressed (held down)
--- @param button number The mouse button to check
--- @return boolean
function Input:is_mouse_button_pressed(button)
  return self.mouse_buttons_down[button] or false
end

--- Check if a specific mouse button was just pressed this frame
--- @param button number The mouse button to check
--- @return boolean
function Input:is_mouse_button_just_pressed(button)
  return self.mouse_buttons_pressed[button] or false
end

--- Check if a specific mouse button was just released this frame
--- @param button number The mouse button to check
--- @return boolean
function Input:is_mouse_button_just_released(button)
  return self.mouse_buttons_released[button] or false
end

--- Get the current mouse position
--- @return Vector2
function Input:get_mouse_position()
  return self.mouse_pos:clone()
end

--- Get the mouse movement delta since the last frame
--- @return Vector2
function Input:get_mouse_delta()
  return self.mouse_delta:clone()
end

-- ----------------------------- INPUT BUFFERING ---------------------------- --

--- Buffer an action for a short duration
--- @param action_name string The name of the action to buffer
function Input:buffer_action(action_name)
  self.buffered_actions[action_name] = self.buffer_time

  if Conduit and self.debug then
    Conduit.input:log("Buffered action '" .. action_name .. "' for " .. tostring(self.buffer_time) .. " seconds.")
  end
end

--- Check if an action is currently buffered_action
--- @param action_name string The name of the action to check
--- @return boolean
function Input:is_action_buffered(action_name)
  return self.buffered_actions[action_name] and self.buffered_actions[action_name] > 0
end

--- Consume a buffered action, removing it from the buffer
--- @param action_name string The name of the action to consume
function Input:consume_buffered_action(action_name)
  self.buffered_actions[action_name] = nil

  if Conduit and self.debug then
    Conduit.input:log("Consumed buffered action '" .. action_name .. "'.")
  end
end

-- ------------------------------ UPDATE CYCLE ------------------------------ --

--- Update the input states; to be called once per frame
--- @param dt number Delta time since last frame
function Input:update(dt)

-- Clear per-frame states
  self.keys_pressed = {}
  self.keys_released = {}
  self.mouse_buttons_pressed = {}
  self.mouse_buttons_released = {}

  -- Update Mouse Delta
  local mx, my = love.mouse.getPosition()
  self.mouse_delta = Vector2(mx - self.mouse_pos.x, my - self.mouse_pos.y)
  self.mouse_pos = Vector2(mx, my)

  -- Update buffered actions
  for buffered_action, time_left in pairs(self.buffered_actions) do
    self.buffered_actions[buffered_action] = time_left - dt
    if self.buffered_actions[buffered_action] <= 0 then
      self.buffered_actions[buffered_action] = nil
    end
  end
end

--- Dispatch an input event to the global Game
--- @param event InputEvent The input event to dispatch
function Input:_dispatch_event(event)
  if not event then
    Conduit.input:error("Tried to dispatch a nil input event!")
    return
  end
  G:input(event)
end

-- --------------------------- INTERNAL CALLBACKS --------------------------- --

--- A key is pressed
--- @param key string The key that was pressed
--- @param scancode string The scancode of the key
--- @param isrepeat boolean Whether the key press is a repeat
function Input:_on_key_pressed(key, scancode, isrepeat)
  self.keys_down[key] = true
  self.keys_pressed[key] = true

  -- Create and dispatch event
  local event = self:_create_key_pressed_event(key, scancode, isrepeat)
  self:_dispatch_event(event)

  self:_log_key("Key pressed: '" .. key .. "'.")
end

--- A key is released
--- @param key string The key that was released
--- @param scancode string The scancode of the key
function Input:_on_key_released(key, scancode)
  self.keys_down[key] = false
  self.keys_released[key] = true

  -- Create and dispatch event
  local event = self:_create_key_released_event(key, scancode)
  self:_dispatch_event(event)

  self:_log_key("Key released: '" .. key .. "'.")
end

--- A mouse button is pressed
--- @param button number The mouse button that was pressed
--- @param x number The x position of the mouse when pressed
--- @param y number The y position of the mouse when pressed
function Input:_on_mouse_pressed(button, x, y)
  self.mouse_buttons_down[button] = true
  self.mouse_buttons_pressed[button] = true

  local button_name = ({
    [1] = "Left",
    [2] = "Right",
    [3] = "Middle",
    [4] = "4",
    [5] = "5"
  })[button] or tostring(button)

  -- Create and dispatch event
  local event = self:_create_mouse_pressed_event(button, x, y)
  self:_dispatch_event(event)


  self:_log_key("Mouse button pressed: '" .. button_name .. "'.")
end

--- A mouse button is released
--- @param button number The mouse button that was released
--- @param x number The x position of the mouse when released
--- @param y number The y position of the mouse when released
function Input:_on_mouse_released(button, x, y)
  self.mouse_buttons_down[button] = false
  self.mouse_buttons_released[button] = true

  local button_name = ({
    [1] = "Left",
    [2] = "Right",
    [3] = "Middle",
    [4] = "4",
    [5] = "5"
  })[button] or tostring(button)

  -- Create and dispatch event
  local event = self:_create_mouse_released_event(button, x, y)
  self:_dispatch_event(event)

  self:_log_key("Mouse button released: '" .. button_name .. "'.")
end

--- The mouse wheel is moved
--- @param x number The horizontal scroll amount
--- @param y number The vertical scroll amount
function Input:_on_mouse_wheel(x, y)
  local event = self:_create_mouse_wheel_event(x, y)
  self:_dispatch_event(event)

  self:_log_key("Mouse wheel moved: " .. (y > 0 and "Up" or (y < 0 and "Down" or "None")) .. ".")
end

--- The mouse is moved
--- @param x number The new x position of the mouse
--- @param y number The new y position of the mouse
--- @param dx number The change in x position since last frame
--- @param dy number The change in y position since last frame
--- @param istouch boolean Whether the movement is from a touch input
function Input:_on_mouse_moved(x, y, dx, dy, istouch)
  local event = self:_create_mouse_motion_event(x, y, dx, dy)
  self:_dispatch_event(event)
end

-- -------------------------- FACTORY EVENT METHODS ------------------------- --

local function _populate_mods()
  return {
    shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift"),
    ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl"),
    alt = love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt"),
    system = love.keyboard.isDown("lgui") or love.keyboard.isDown("rgui")
  }
end

function Input:_create_key_pressed_event(key, scancode, is_repeat)
  local event_data = {
    key = key,
    scancode = scancode,
    is_repeat = is_repeat
  }
  local mods = _populate_mods()
  return InputEvent(InputEvent.KEY_PRESSED, event_data, mods)
end

function Input:_create_key_released_event(key, scancode)
  local event_data = {
    key = key,
    scancode = scancode
  }
  local mods = _populate_mods()
  return InputEvent(InputEvent.KEY_RELEASED, event_data, mods)
end

function Input:_create_mouse_pressed_event(button, x, y)
  local event_data = {
    button = button,
    position = Vector2(x, y)
  }
  local mods = _populate_mods()
  return InputEvent(InputEvent.MOUSE_PRESSED, event_data, mods)
end

function Input:_create_mouse_released_event(button, x, y)
  local event_data = {
    button = button,
    position = Vector2(x, y)
  }
  local mods = _populate_mods()
  return InputEvent(InputEvent.MOUSE_RELEASED, event_data, mods)
end

function Input:_create_mouse_wheel_event(x, y)
  local event_data = {
    wheel = Vector2(x, y)
  }
  local mods = _populate_mods()
  return InputEvent(InputEvent.MOUSE_WHEEL, event_data, mods)
end

function Input:_create_mouse_motion_event(x, y, dx, dy)
  local event_data = {
    position = Vector2(x, y),
    delta = Vector2(dx, dy)
  }
  local mods = _populate_mods()
  return InputEvent(InputEvent.MOUSE_MOVED, event_data, mods)
end


-- ----------------------------- SPECIAL METHODS ---------------------------- --

--- Helper to get the action name for a given key
--- Returns nil if the key is not mapped to any action
--- @param key string The key to check
--- @return string|nil The action name or nil
function Input:_get_key_action(key)
  for action_name, bindings in pairs(self.action_map) do
    for _, bound_key in ipairs(bindings.keyboard) do
      if bound_key == key then
        return action_name
      end
    end
  end
  return nil
end

function Input:_log_key(message)
  if Conduit and self.debug and self.log_keys then
    Conduit.input:log(message)
  end
end

-- --------------------------- GLOBAL KEY HELPERS --------------------------- --

Input.MOUSELEFT = 1
Input.MOUSERIGHT = 2
Input.MOUSEMIDDLE = 3
Input.MOUSE4 = 4
Input.MOUSE5 = 5
