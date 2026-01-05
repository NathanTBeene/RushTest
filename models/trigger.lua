Trigger = {
  IMMEDIATE = 0,    -- Right away (next frame)
  AFTER = 1,        -- waits [delay] seconds before triggering
  BEFORE = 2,       -- Runs right away, but completes after [delay] seconds
  EASE = 3,         -- Smoothly interpolates over [delay] seconds
  CONDITION = 4     -- Waits until a condition is met (function returns true)
}
