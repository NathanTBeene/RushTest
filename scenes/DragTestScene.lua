--- @scene DragTestScene
--- A test scene to demonstrate drag-and-drop functionality.
local DragTestScene = Scene:extend("DragTestScene")

function DragTestScene:load()
    DragTestScene.super.load(self)

    self.draggableRect = ColorRect("DraggableRect", Color.blue)
    self.draggableRect.position = Vector2(150, 150)
    self.draggableRect.size = Vector2(100, 100)
    self.draggableRect.debug = true

    self:add_child(self.draggableRect)
end

function DragTestScene:update(dt)
    DragTestScene.super.update(self)

    if self.draggableRect:is_mouse_over() then
      self.draggableRect:set_color(Color.red)
    else
      self.draggableRect:set_color(Color.blue)
    end
end

function DragTestScene:draw()
    DragTestScene.super.draw(self)
end

return DragTestScene
