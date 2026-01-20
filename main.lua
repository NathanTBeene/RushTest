require("network")
require("conf")
require("engine.class")       -- Base Class implementation needed for everything.

-- --------------------------------- IMPORTS -------------------------------- --
-- Functions
require("functions.utility")

-- Models
require("models.vector2")
require("models.transform")
require("models.color")
require("models.rect")

-- Engine Components
require("engine.events.event")
require("engine.events.inputevent")
require("engine.input")
require("engine.node")
require("engine.control")
require("engine.colorrect")

-- Systems
require("game")
require("globals")

-- Modules
lick = require("modules.lick") -- Allows hot reloading
lick.updateAllFiles = true
lick.reset = true
lick.clearPackages = true
lick.debug = true

lick.debugPrint = function(msg, prefix)
  Conduit.system:log((prefix or "[Lick] ") .. msg)
end

-- ---------------------------------- SETUP --------------------------------- --

--- Global Game Instance
--- This is where the main game logic will be handled.
--- @type Game
G = Game()

--- Global Input Instance
--- This is where all input events will be created and managed.
--- @type Input
I = Input()

-- ------------------------------ LOVE METHODS ------------------------------ --

function love.load()
  G:start_up()
end

function love.update(dt)
  Conduit:update()
  G:update(dt)
  I:update(dt)
end

function love.draw()
  G:draw()
end

function love.quit()
  Conduit:shutdown()
end


-- ----------------------------- INPUT HANDLERS ----------------------------- --

function love.keypressed(key, scancode, isrepeat)
  I:_on_key_pressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
  I:_on_key_released(key, scancode)
end

function love.mousepressed(x, y, button)
  I:_on_mouse_pressed(button, x, y)
end

function love.mousereleased(x, y, button)
  I:_on_mouse_released(button, x, y)
end

function love.wheelmoved(x, y)
  I:_on_mouse_wheel(x, y)
end

function love.mousemoved(x, y, dx, dy, istouch)
  I:_on_mouse_moved(x, y, dx, dy, istouch)
end
