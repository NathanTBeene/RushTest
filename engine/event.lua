---@class Event
Event = Class:extend()

--- Represents an event that can be triggered and listened to within the system.
--- Provides mechanisms for subscribing, unsubscribing, and notifying event handlers.
--- Useful for implementing observer patterns and decoupling components.

function Event:init(config)
  self.trigger = config.trigger or Trigger.IMMEDIATE
  self.func = config.func or function() return true end
  self.delay = config.delay or 0
  self.complete = false

  -- Timing
  self.start_time = nil
  self.elapsed = 0

  -- Setup for ease trigger
  if self.trigger == Trigger.EASE then
    self.ease = {
      type = config.ease or Ease.LERP,
      ref_table = config.ref_table or nil,
      ref_value = config.ref_value or nil,
      start_value = nil,
      end_value = config.end_value
    }

    self.func = config.func or function(t) return t end
  end

  -- Setup for Condition Trigger
  if self.trigger == Trigger.CONDITION then
    self.condition = {
      ref_table = config.ref_table or nil,
      ref_value = config.ref_value or nil,
      stop_val = config.stop_val or nil
    }

    self.func = config.func or function()
      return self.condition.ref_table[self.condition.ref_value] == self.condition.stop_val
    end
  end
end

function Event:update(dt)
    if self.complete then return true end

    -- Initialize start time on first update
    if not self.start_time then
        self.start_time = 0
    end
    self.elapsed = self.elapsed + dt

    -- Handle different trigger types
    if self.trigger == 'immediate' then
        self.complete = self.func()
        return self.complete
    end

    if self.trigger == 'after' then
        if self.elapsed >= self.delay then
            self.complete = self.func()
        end
        return self.complete
    end

    if self.trigger == 'ease' then
        -- Lazy initialize start value (allows chaining eases)
        if not self.ease.start_val then
            self.ease.start_val = self.ease.ref_table[self.ease.ref_value]
        end

        if self.elapsed < self.delay then
            -- Calculate progress (0 to 1)
            local t = self.elapsed / self.delay

            -- Apply easing function
            if self.ease.type == 'lerp' then
                -- Linear interpolation
                t = t
            elseif self.ease.type == 'quad' then
                -- Quadratic ease out
                t = 1 - (1 - t) * (1 - t)
            elseif self.ease.type == 'cubic' then
                -- Cubic ease out
                t = 1 - math.power(1 - t, 3)
            elseif self.ease.type == 'elastic' then
                -- Elastic ease out (bouncy)
                if t == 0 or t == 1 then
                    -- Skip calculation at edges
                else
                    t = math.power(2, -10 * t) * math.sin((t * 10 - 0.75) * 2 * math.pi / 3) + 1
                end
            end

            -- Interpolate value
            local value = self.ease.start_val + (self.ease.end_val - self.ease.start_val) * t
            -- Apply optional transform function
            self.ease.ref_table[self.ease.ref_value] = self.func(value)
        else
            -- Ensure we hit exact end value
            self.ease.ref_table[self.ease.ref_value] = self.func(self.ease.end_val)
            self.complete = true
        end
        return self.complete
    end

    if self.trigger == 'condition' then
        self.complete = self.func()
        return self.complete
    end

    return false
end

---@class EventManager

EventManager = Class:extend()

function EventManager:init()
  self.queues = {
    base = {},
    ui = {},
    game = {}
  }
end

function EventManager:add_event(event, queue, front)
  queue = queue or 'base'

  if event:is(Event) then
    if front then
      table.insert(self.queues[queue], 1, event)
    else
      self.queues[queue][#self.queues[queue] + 1] = event
    end
  end
end

function EventManager:clear_queue(queue)
  if not queue then
    -- clear all queues
    for qname, _ in pairs(self.queues) do
      self.queues[qname] = {}
    end
  else
    self.queues[queue] = {}
  end
end

function EventManager:update(dt)
  -- Process each queue independently (parallel events)
  for queue_name, queue in pairs(self.queues) do
    if #queue > 0 then
      -- Process the first event in the queue
      if queue[1]:update(dt) then
        -- Event is complete, remove it from the queue
        table.remove(queue, 1)
      end
    end
  end
end

function EventManager:has_events(queue)
  if queue then
    return #self.queues[queue] > 0
  else
    -- Check if any queue has events
    for _, q in pairs(self.queues) do
      if #q > 0 then
        return true
      end
    end
    return false
  end
end
