
function delay(time, queue)
  G.E_MANAGER:add_event(Event({
    trigger = Trigger.AFTER,
    delay = time or 1,
    func = function() return true end,
  }), queue)
end

function ease(ref_table, ref_value, target, duration, ease_type, queue)
  G.E_MANAGER:add_event(Event({
    trigger = Trigger.EASE,
    ref_table = ref_table,
    ref_value = ref_value,
    end_value = target,
    delay = duration or 0.3,
    ease = ease_type or Ease.LERP,
  }), queue)
end

function ease_value(ref_table, ref_value, target, duration, ease_type, transform_func, queue)
  G.E_MANAGER:add_event(Event({
    trigger = Trigger.EASE,
    ref_table = ref_table,
    ref_value = ref_value,
    end_value = target,
    delay = duration or 0.3,
    ease = ease_type or Ease.LERP,
    func = transform_func or function(t) return math.floor(t) end,
  }), queue)
end

function wait_for(ref_table, ref_value, target_value, then_func, queue)
  G.E_MANAGER:add_event(Event({
    trigger = Trigger.CONDITION,
    ref_table = ref_table,
    ref_value = ref_value,
    stop_val = target_value,
    func = then_func or function() return true end,
  }), queue)
end
