local State = { states = {}, current = nil }

---@param name string
---@param state table
function State.register(name, state)
    State.states[name] = state
end

---@param name string
function State.switch(name, ...)
    local next_state = State.states[name]
    assert(next_state, "unknown state: " .. tostring(name))

    local prev = State.current
    if prev and prev.leave then prev.leave() end

    State.current = next_state
    if next_state.enter then next_state.enter(...) end
end

function State.install(callbacks)
    for _, name in ipairs(callbacks) do
        love[name] = function(...)
            local s = State.current
            if s and s[name] then return s[name](...) end
        end
    end
end

return State
