-- Find modules in the modules/ directory
package.path = package.path .. ";modules/?.lua;modules/?/init.lua"
require("conf")
require("engine.class")       -- Base Class implementation needed for everything.

-- --------------------------------- IMPORTS -------------------------------- --
-- Models
require("models.vector2")
require("models.transform")
require("models.color")
require("models.rect")

-- Engine Components
require("engine.node")
require("engine.control")
require("engine.draggable")
require("engine.colorrect")
require("engine.scene")

-- Systems
require("game")
require("globals")
require("network")

-- Modules
lick = require("modules.lick") -- Allows hot reloading
lick.updateAllFiles = true
lick.reset = true
lick.clearPackages = true
lick.debug = true

-- ---------------------------------- SETUP --------------------------------- --

--- Global Game Instance
--- This is where the main game logic will be handled.
--- @type Game
G = Game()

-- ------------------------------ LOVE METHODS ------------------------------ --

function love.load()
  G:start_up()
end

function love.update(dt)
  Conduit:update()
  G:update(dt)
end

function love.quit()
  Conduit:shutdown()
end

function love.draw()
  G:draw()
end

function love.keypressed(key)
  G:key_pressed(key)
end

function love.keyreleased(key)
  G:key_released(key)
end

function love.mousepressed(x, y, button)
  G:mouse_pressed(x, y, button)
end

function love.mousereleased(x, y, button)
  G:mouse_released(x, y, button)
end
