---@class DraggableMixin

DraggableMixin = {}

function DraggableMixin:init_draggable()
  self._dragging = false
  self._drag_offset = Vector2(0, 0)
end

function DraggableMixin:start_drag()
  if self:is_dragging() then return end

  local pos = I:get_mouse_position()
  self._drag_offset = pos - self.position
  self._dragging = true
end

function DraggableMixin:update_drag()
  if not self:is_dragging() then return end

  local pos = I:get_mouse_position()
  self.position = pos - self._drag_offset
end

function DraggableMixin:stop_drag()
  self._dragging = false
  self._drag_offset = Vector2(0, 0)
end

-- -------------------------------- CHECKERS -------------------------------- --

function DraggableMixin:is_dragging()
  return self._dragging
end

return DraggableMixin
