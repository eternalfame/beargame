local L = require('locale')

local Dialogue = {}

local DEFAULT_HEIGHT = 2

---@param step table
---@param ctx table
---@param id string|nil
---@return table
function Dialogue.entry(step, ctx, id)
    if step.say then
        local talker = ctx.actors[step.say]
        assert(talker, ("dialogue '%s': unknown actor '%s'"):format(id or "?", step.say))
        return {
            timer  = step.time,
            text   = L.t(step.key),
            talker = talker,
            height = step.height or DEFAULT_HEIGHT,
        }
    elseif step.act then
        return {
            timer = step.time or 0,
            func  = function() step.act(ctx) end,
        }
    end
    return { timer = step.time or 0 }
end

---@param script { id: string, steps: table[] }
---@param ctx table
---@return table queue
function Dialogue.build(script, ctx)
    local queue = {}
    for _, step in ipairs(script.steps) do
        queue[#queue + 1] = Dialogue.entry(step, ctx, script.id)
    end
    if ctx.on_finish then
        queue[#queue + 1] = { timer = 0, func = ctx.on_finish }
    end
    return queue
end

return Dialogue