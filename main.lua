-- Find modules in the modules/ directory
package.path = package.path .. ";modules/?.lua;modules/?/init.lua"

require("engine.class")       -- Base Class implementation needed for everything.
require("models.vector2")
require("models.transform")
require("models.color")
require("engine.node")
require("engine.scene")
require("engine.control")
require("engine.colorrect")
require("engine.event")
require("engine.scene")
require("game")
require("globals")

Conduit = require("conduit")

lick = require("modules.lick.lick")
lick.reset = true

G = Game()

function love.load()
  -- Conduit and Debug setup
  Conduit:init({
    port = 8080,
    timestamps = true,
    max_logs = 1000,
    max_watchables = 100,
    refresh_interval = 100
  })

  D_SYSTEM = Conduit:console("system")
  D_SYSTEM:clear()
  D_SYSTEM:log("Game Starting...")

  Conduit:console("gameplay")

  Conduit.gameplay:clear()
  Conduit.gameplay:watch("FPS", function() return love.timer.getFPS() end)
  Conduit.gameplay:watch("Delta Time", function() return love.timer.getDelta() end)
  Conduit.gameplay:log("Gameplay console initialized.")

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
