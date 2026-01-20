--- @class Event : Class
Event = Class:extend("Event")

---* Base event for all other kinds.
---* All events need a type to differenciate themselves.
---* types are typically defined in the respective event subclasses.

--- Constructor
--- @param event_type string The type of the event.
function Event:init(event_type)
  self.event_type = event_type
  self.consumed = false
  self.timestamp = love.timer.getTime()
end

--- Marks the event as consumed, preventing further processing.
function Event:consume()
  self.consumed = true
  self:_consume()
end

--- Internal method to consume the event.
--- (This method can be overridden by subclasses if needed.)
function Event:_consume()
end

--- Checks if the event has been consumed.
--- @return boolean True if the event is consumed, false otherwise.
function Event:is_consumed()
  return self.consumed
end
