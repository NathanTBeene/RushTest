---@class Draggable : Control
Draggable = Control:extend("Draggable")

---* A Draggable is a Control that can be clicked and dragged around the screen.

function Draggable:init()
  Draggable.super.init(self)
  self.is_dragging = false
  self.drag_offset = Vector2(0, 0)

  Conduit.system:log("Draggable initialized " .. tostring(self))
end

function Draggable:_update(dt)
  self:drag_update()
end

function Draggable:_draw()
  self:draw_bounds()
end

function Draggable:drag_start()
  if self.is_dragging then return end
  self.is_dragging = true
  Conduit.system:log("Drag started for Draggable" .. tostring(self))
end

function Draggable:drag_update()
  if not self.is_dragging then return end
  Conduit.system:log("Drag updated for Draggable" .. tostring(self))
end

function Draggable:drag_end()
  if not self.is_dragging then return end
  Conduit.system:log("Drag ended for Draggable" .. tostring(self))
  self.is_dragging = false
end

-- function Draggable:__tostring()
--   return "Draggable@" .. tostring(self.transform.position)
-- end
