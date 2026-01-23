require("network")
require("conf")
require("engine.class")       -- Base Class implementation needed for everything.
require("engine.cursor")      -- Cursor definitions

-- --------------------------------- IMPORTS -------------------------------- --
-- Functions
-- require("functions.utility")

-- Models
require("models.vector2")
require("models.transform")
require("models.color")
require("models.rect")
require("models.style")

-- Engine Components
require("engine.events.event")
require("engine.events.inputevent")
require("engine.input")
require("engine.node")
require("engine.control")
require("engine.colorrect")
require("engine.button")

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

function love.run()
  local dt = 0
  local dt_smooth = 1/60 -- Initialize for delta smoothing
  local accumulator = 0
  local run_time = 0

  if love.load then love.load() end
  if love.timer then love.timer.step() end

  return function()
    run_time = love.timer.getTime()

    -- Event Handling
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
            return a or 0
          end
        end
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- Get Delta Time
    if love.timer then dt = love.timer.step() end
    dt_smooth = math.min(0.8 * dt_smooth + 0.2 * dt, 0.1)

    -- Get fixed timestep
    local FIXED_DT = G.SETTINGS.FPS_CAP > 0 and 1 / G.SETTINGS.FPS_CAP or 1/60 -- Default to 60 FPS if no cap

    -- Fixed Timestep Physics
    accumulator = accumulator + dt
    while accumulator >= FIXED_DT do
      if love.physics_update then
        love.physics_update(FIXED_DT)
      end
      accumulator = accumulator - FIXED_DT
    end

    -- Variable Timestep Update
    if love.update then love.update(dt_smooth) end

    -- Draw
    if love.graphics and love.graphics.isActive() then
      love.graphics.clear()
      if love.draw then love.draw() end
      love.graphics.present()
    end

    -- Frame Rate Limiting
    run_time = math.min(love.timer.getTime() - run_time, 0.1)
    if G.SETTINGS.FPS_CAP > 0 then
      local frame_time = 1 / G.SETTINGS.FPS_CAP
      if run_time < frame_time then
        love.timer.sleep(frame_time - run_time)
      end
    else
      -- Unlimited FPS, yield to avoid CPU hogging
      love.timer.sleep(0.001)
    end
  end
end

function love.load()
  lick.init() -- Initialize Lick's file watching
  G:start_up()
end

-- Recieves dt_smooth from love.run
-- Runs as fast as possible but dt is smoothed
-- to avoid large jumps
function love.update(dt)
  lick.check() -- Check for file changes
  Conduit:update()
  I:update(dt)
end

-- Fixed Timestep Physics Update
-- Dt is fixed to 1 / FPS_CAP
function love.physics_update(dt)
  G:update(dt)
end

function love.draw()
  G:draw()
  lick.drawDebug() -- Draw Lick's debug info
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
