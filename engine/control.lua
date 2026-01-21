---@class Control : Node
Control = Node:extend("Control")

local SignalMixin = require("engine.mixins.signal")
Control:implement(SignalMixin)

---* Controls are nodes that are considered UI and are specifically meant to be
---* interacted with separately from the rest of the game world. They are on their
---* own layer, and are not affected by the game world's physics or other systems.
---* Controls can usually be interacted with via mouse or keyboard input and will emit
---* signals when interacted with.

function Control:init()
  Control.super.init(self)
  self.style = nil

  -- signals
  self:init_signals()
  self:define_signal("mouse_down")
  self:define_signal("mouse_up")
  self:define_signal("clicked")
  self:define_signal("mouse_entered")
  self:define_signal("mouse_exited")

  -- state_tracking
  self.config.is_mouse_over = false
  self.config.was_clicked = false

  -- Connect Signals
  self:connect("mouse_entered", function()
    Conduit.events:log(string.format("%s mouse_entered", self))
  end)
  self:connect("mouse_exited", function()
    Conduit.events:log(string.format("%s mouse_exited", self))
  end)
  self:connect("mouse_down", function()
    Conduit.events:log(string.format("%s mouse_down", self))
  end)
  self:connect("mouse_up", function()
    Conduit.events:log(string.format("%s mouse_up", self))
  end)
  self:connect("clicked", function()
    Conduit.events:log(string.format("%s clicked", self))
  end)
end

-- ---------------------------- LIFECYCLE METHODS --------------------------- --

function Control:_load()
end

function Control:_input(event)

  -- Track Click state
  if event.event_type == InputEvent.MOUSE_PRESSED and event:is_button(Input.MOUSELEFT) then
    if self:is_mouse_over() then
      self.config.was_clicked = true
      self:emit("mouse_down", self)
    end
  end

  if event.event_type == InputEvent.MOUSE_RELEASED and event:is_button(Input.MOUSELEFT) then
    if self:is_mouse_over() then
      self:emit("mouse_up", self)
      if self.config.was_clicked then
        self:emit("clicked", self)
      end
    end
    self.config.was_clicked = false
  end
end

function Control:_update(dt)

  if self:is_mouse_over() then
    if not self.config.is_mouse_over then
      self.config.is_mouse_over = true
      self:emit("mouse_entered", self)
    end
  else
    if self.config.is_mouse_over then
      self.config.is_mouse_over = false
      self:emit("mouse_exited", self)
    end
  end
end

function Control:_draw()
end

-- -------------------------------- CHECKERS -------------------------------- --

--- Checks if the mouse is currently over this control
--- @return boolean True if the mouse is over the control, false otherwise
function Control:is_mouse_over()
  local mousePos = I:get_mouse_position()
  return self:is_in_bounds(mousePos)
end
