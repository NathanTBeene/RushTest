
function Game:set_globals()
  self.VERSION = "0.1.0"

  -- Feature Flags
  self.F = {
    DEBUG = true,
    SOUND_ENABLED = false
  }

  -- Window
  self.WINDOW = {
    WIDTH = 800,
    HEIGHT = 600
  }

  if self.F.DEBUG then
    print("")
    print("Rush Test Game")
    print("Game Version: " .. self.VERSION)
  end
end
