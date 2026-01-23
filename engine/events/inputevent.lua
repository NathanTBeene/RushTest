---@class InputEvent : Event
InputEvent = Event:extend("InputEvent")

---* An InputEvent helps to define and manage input events such as key presses and mouse movements.
---* All inputs are represented as InputEvent instances, which encapsulate details about the event type,
---* associated data, and modifier keys.

local PropertyMixin = require("engine.mixins.property")
InputEvent:implement(PropertyMixin)

--- Constructor for InputEvent
--- @param event_type string The type of input event
--- @param event_data {key: string, button: number, scancode: string, is_repeat: boolean, position: Vector2, delta: Vector2, wheel: Vector2} Additional data associated with the event
--- @param mods {shift: boolean, ctrl: boolean, alt: boolean, system: boolean} Modifier keys states
function InputEvent:init(event_type, event_data, mods)
  InputEvent.super.init(self,event_type)
  self.data = event_data or {}
  self.mods = mods or {}

  -- Set up properties
  self:init_properties()

end

-- -------------------------- PROPERTY DEFINITIONS -------------------------- --

InputEvent:define_property("event_type", function(self) return self.event_type end)
InputEvent:define_property("key", function(self) return self.data.key end)
InputEvent:define_property("button", function(self) return self.data.button end)
InputEvent:define_property("scancode", function(self) return self.data.scancode end)
InputEvent:define_property("position", function(self) return self.data.position end)
InputEvent:define_property("is_repeat", function(self) return self.data.is_repeat or false end)
InputEvent:define_property("wheel", function(self) return self.data.wheel end)
InputEvent:define_property("delta", function(self) return self.data.delta end)

-- ------------------------------- EQUIVELENCE ------------------------------ --

--- Check if the event matches a specific key, button, or scancode
--- @param key string The key to check against
--- @return boolean True if the event matches the key
function InputEvent:is_key(key)
  return self.data.key == key
end

--- Check if the event matches a specific mouse button
--- @param button number The mouse button to check against
--- @return boolean True if the event matches the button
function InputEvent:is_button(button)
  return self.data.button == button
end

--- Check if the event matches a specific scancode
--- @param scancode string The scancode to check against
--- @return boolean True if the event matches the scancode
function InputEvent:is_scancode(scancode)
  return self.data.scancode == scancode
end

--- Check if a specific modifier key was active during the event
--- @param mod string The modifier key to check (e.g., "shift", "ctrl", "alt", "system")
--- @return boolean True if the modifier key was active
function InputEvent:has_mod(mod)
  return self.mods[mod] == true
end

-- ------------------------------ TYPE CHECKERS ----------------------------- --

--- Check if the event is a key event (pressed or released)
--- @return boolean True if the event is a key event
function InputEvent:is_key_event()
  return self.event_type == InputEvent.KEY_PRESSED or self.event_type == InputEvent.KEY_RELEASED
end

--- Check if the event is a mouse event (pressed, released, moved, or wheel)
--- @return boolean True if the event is a mouse event
function InputEvent:is_mouse_event()
  return self.event_type == InputEvent.MOUSE_PRESSED or self.event_type == InputEvent.MOUSE_RELEASED or
         self.event_type == InputEvent.MOUSE_MOVED or self.event_type == InputEvent.MOUSE_WHEEL
end

--- Check if the event is a mouse wheel event
--- @return boolean True if the event is a mouse wheel event
function InputEvent:is_mouse_wheel()
  return self.event_type == InputEvent.MOUSE_WHEEL
end

--- Check if the event is a mouse motion event
--- @return boolean True if the event is a mouse motion event
function InputEvent:is_mouse_motion()
  return self.event_type == InputEvent.MOUSE_MOVED
end

-- ------------------------------- EVENT TYPES ------------------------------ --

InputEvent.KEY_PRESSED = "key_pressed"
InputEvent.KEY_RELEASED = "key_released"
InputEvent.MOUSE_PRESSED = "mouse_pressed"
InputEvent.MOUSE_RELEASED = "mouse_released"
InputEvent.MOUSE_MOVED = "mouse_moved"
InputEvent.MOUSE_WHEEL = "mouse_wheel"
