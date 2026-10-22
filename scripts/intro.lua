local world = require('systems.world')

local SPEED_INTRO  = 1.0
local SPEED_NORMAL = 6.0  -- change for debug purposes

return {
    id = "intro",
    steps = {
        { time = 1 },
        {
            time = 1,
            act = function(ctx)
                local hero, girl = ctx.actors.hero, ctx.actors.girl
                local bs = world.block_size

                hero:setSpeed(SPEED_INTRO)
                girl:setSpeed(SPEED_INTRO)
                if world:walkable(girl.x / bs, girl.y / bs - 2) then
                    girl:setTarget({ x = girl.x, y = girl.y - bs * 2 })
                else
                    girl:setTarget({ x = girl.x, y = girl.y - bs * 3 })
                end
                hero:setTarget({ x = hero.x, y = hero.y + bs })
            end
        },
        { say = "girl", key = "intro.invite",    time = 5, height = 4 },
        { say = "hero", key = "intro.surprised", time = 3, height = 2 },
        { say = "girl", key = "intro.how_could", time = 2, height = 2 },
        { say = "girl", key = "intro.pause",     time = 1, height = 1 },
        { say = "girl", key = "intro.problems",  time = 2, height = 2 },
        { say = "girl", key = "intro.forest",    time = 3, height = 3 },
        { say = "hero", key = "intro.lets_go",   time = 2, height = 2 },
        { time = 1 },
        { say = "hero", key = "intro.controls",  time = 3, height = 3 },
        {
            act = function(ctx)
                ctx.actors.hero:setSpeed(SPEED_NORMAL)
                ctx.actors.girl:setSpeed(SPEED_NORMAL)
            end
        },
    },
}
