require("network")
require("conf")
require("engine.class")       -- Base Class implementation needed for everything.

-- --------------------------------- IMPORTS -------------------------------- --
-- Models
require("models.vector2")
require("models.transform")
require("models.color")
require("models.rect")

-- Engine Components
require("engine.input")
require("engine.node")
require("engine.control")
require("engine.colorrect")
require("engine.scene")

-- Systems
require("game")
require("globals")

-- Modules
lick = require("modules.lick") -- Allows hot reloading
lick.updateAllFiles = true
lick.reset = true
lick.clearPackages = true
lick.debug = true
lick.onReload = function(files)
  if type(Conduit.consoles) ~= "table" then
    Conduit.system:error("No consoles found in Conduit.consoles!\n Type found: " .. type(Conduit.consoles))
    return
  end
  for _, console in pairs(Conduit.consoles) do
    console:clear()
  end
end

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
  I:update(dt)
  G:update(dt)
end

function love.draw()
  G:draw()
end

function love.quit()
  Conduit:shutdown()
end



-- ----------------------------- INPUT HANDLERS ----------------------------- --

function love.keypressed(key)
  I:_on_key_pressed(key)
end

function love.keyreleased(key)
  I:_on_key_released(key)
end

function love.mousepressed(x, y, button)
  I:_on_mouse_pressed(x, y, button)
end

function love.mousereleased(x, y, button)
  I:_on_mouse_released(x, y, button)
end
