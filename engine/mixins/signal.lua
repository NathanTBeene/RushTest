---@class SignalMixin
local SignalMixin = {}

---* A basic signal system mixin.
---* You define signals and then connect callbacks to them.
---* When a signal is emitted, all connected callbacks are invoked.
---* Callbacks can optionally have a target object passed as the first argument.

--- Initializes the signal system for the object.
function SignalMixin:init_signals()
  self._signals = {}
end

--- Defines a new signal with the given name.
---@param signal_name string The name of the signal to define.
function SignalMixin:define_signal(signal_name)
  self._signals[signal_name] = self._signals[signal_name] or {connections = {}}
end

--- Connects a callback to a signal.
---@param signal_name string The name of the signal to connect to.
---@param callback function The callback function to invoke when the signal is emitted.
---@param target table? An optional target object to pass as the first argument to the callback
function SignalMixin:connect(signal_name, callback, target)
  if not self._signals[signal_name] then
    error("Signal '" .. signal_name .. "' is not defined.")
  end

  local connection = {
    callback = callback,
    target = target,
    connected = true
  }

  table.insert(self._signals[signal_name].connections, connection)
  return connection
end

--- Disconnects a previously connected callback from a signal.
---@param signal_name string The name of the signal to disconnect from.
---@param connection table The connection object returned by the connect method.
function SignalMixin:disconnect(signal_name, connection)
  if not self._signals[signal_name] then
    error("Signal '" .. signal_name .. "' is not defined.")
  end

  for i, conn in ipairs(self._signals[signal_name].connections) do
    if conn == connection then
      table.remove(self._signals[signal_name].connections, i)
      break
    end
  end
end

--- Disconnects all callbacks from a signal.
---@param signal_name string The name of the signal to disconnect all callbacks from.
function SignalMixin:disconnect_all(signal_name)
  if not self._signals[signal_name] then
    error("Signal '" .. signal_name .. "' is not defined.")
  end

  self._signals[signal_name].connections = {}
end

function SignalMixin:emit(signal_name, ...)
  if not self._signals[signal_name] then
    error("Signal '" .. signal_name .. "' is not defined.")
  end

  local conns = self._signals[signal_name].connections
  for _, connection in ipairs(conns) do
    if connection.connected then
      if connection.target then
        connection.callback(connection.target, ...)
      else
        connection.callback(...)
      end
    end
  end
end

--- Checks if there are any connections for a given signal.
---@param signal_name string The name of the signal to check.
function SignalMixin:has_connections(signal_name)
  if not self._signals[signal_name] then
    error("Signal '" .. signal_name .. "' is not defined.")
  end

  return #self._signals[signal_name].connections > 0
end

return SignalMixin
