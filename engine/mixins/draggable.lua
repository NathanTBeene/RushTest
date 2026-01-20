---@class DraggableMixin

local DraggableMixin = {}

--* Adds drag functionality to an object.
--* Will update the transform of the object when dragging to
--* match the mouse position.

--- Initializes the draggable properties.
--- @param drag_type? string The type of drag (optional, default to "default")
function DraggableMixin:init_draggable(drag_type)
  self.drag_type = drag_type or "default" -- Drag Type is for matching with a dropzone
  self.can_drag = true
  self.is_dragging = false
  self.drag_threshold = 2
  self.drag_start_position = nil
  self.clicked = false
  self.drag_offset = Vector2.ZERO
end

--- Starts the drag operation.
--- Grabs start position for calculating offset and
--- returning to original position if needed.
function DraggableMixin:drag_start()
  if not self.can_drag then return end

  self.is_dragging = true
  self.drag_start_position = I:get_mouse_position()
  self.drag_offset = self.global_position - self.drag_start_position
end

--- Updates the position of the object while dragging.
--- @param dt number Delta time since last update
--- TODO: Add lerping for smoother dragging
function DraggableMixin:drag_update(dt)
  if not self.can_drag then return end

  if self.is_dragging then
    local pos = I:get_mouse_position()
    self.global_position = pos + self.drag_offset
  end
end

--- Ends the drag operation.
function DraggableMixin:drag_end()
  if not self.can_drag then return end

  self.is_dragging = false
end

return DraggableMixin
