if not Conduit then
  Conduit = require("conduit")

  --- Initialize Conduit for debugging
  Conduit:init({
    port = 8080,
    timestamps = true,
    max_logs = 1000,
    max_watchables = 100,
    refresh_interval = 100
  })
end

Conduit:console("system")
Conduit:console("gameplay")
