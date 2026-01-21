---@class Cursor : Class
Cursor = Class:extend("Cursor")

---* Allows for controlling the appearance and behavior of the mouse cursor within the application.
---* This includes changing the cursor icon based on context, such as hovering over different UI elements


function Cursor:init()
  self.current_cursor = nil
end

function Cursor:set_cursor(cursor_type)
  if self.current_cursor ~= cursor_type then
    love.mouse.setCursor(love.mouse.getSystemCursor(cursor_type))
    self.current_cursor = cursor_type
  end
end

function Cursor:reset_cursor()
  love.mouse.setCursor()
  self.current_cursor = nil
end

-- ---------------------------- CURSOR CONSTANTS ---------------------------- --
Cursor.ARROW = "arrow"
Cursor.IBEAM = "ibeam"
Cursor.CROSSHAIR = "crosshair"
Cursor.HAND = "hand"
Cursor.RESIZE_N = "size_n"
Cursor.RESIZE_E = "size_e"
Cursor.RESIZE_S = "size_s"
Cursor.RESIZE_W = "size_w"
Cursor.RESIZE_NE = "size_ne"
Cursor.RESIZE_NW = "size_nw"
Cursor.RESIZE_SE = "size_se"
Cursor.RESIZE_SW = "size_sw"
Cursor.WAIT = "wait"
Cursor.WAITARROW = "waitarrow"
Cursor.NONE = "none"
Cursor.NO = "no"
