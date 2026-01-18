---@class Input : Class
Input = Class:extend("Input")

function Input:init()
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
end

--- Remove an action from the action map
--- @param action_name string The name of the action to remove
function Input:remove_action(action_name)
  self.action_map[action_name] = nil
end

--- Load multiple actions from a table
--- @param actions table A table of action_name -> bindings
function Input:load_actions(actions)
  for name, bindings in pairs(actions) do
    self:add_action(name, bindings)
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
  if not bindings then return false end

  -- Check keyboard bindings
  for _, key in ipairs(bindings.keyboard) do
    if self.keys_pressed[key] then
      return true
    end
  end

  -- Check mouse bindings
  for _, button in ipairs(bindings.mouse) do
    if self.mouse_buttons_pressed[button] then
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

-- --------------------------- INTERNAL CALLBACKS --------------------------- --

--- A key is pressed
--- @param key string The key that was pressed
function Input:_on_key_pressed(key)
  self.keys_down[key] = true
  self.keys_pressed[key] = true
end

--- A key is released
--- @param key string The key that was released
function Input:_on_key_released(key)
  self.keys_down[key] = false
  self.keys_released[key] = true
end

--- A mouse button is pressed
--- @param button number The mouse button that was pressed
function Input:_on_mouse_pressed(button)
  self.mouse_buttons_down[button] = true
  self.mouse_buttons_pressed[button] = true
end

--- A mouse button is released
--- @param button number The mouse button that was released
function Input:_on_mouse_released(button)
  self.mouse_buttons_down[button] = false
  self.mouse_buttons_released[button] = true
end
