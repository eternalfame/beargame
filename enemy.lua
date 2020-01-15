require('globals')
local hero = require('hero')
local world = require('world')
local table = require('ext_table')

-- наследуем врага от героя
local enemy = {
    sounds = {
        dead = love.audio.newSource("fx/death.ogg", "static")
    }
}

function enemy:init()
    self.sounds.dead:setVolume(0.5)
    for i = 1, table.length(world.enemy_spawns) do
        self[i] = deepcopy(hero)
        self[i].image = love.graphics.newImage("img/inverted.png")
        self[i].del = 8
    end
end

function enemy:get(x, y)
    for _, instance in ipairs(self) do
        if table.length(instance) > 0 then
            local i_x = instance.x
            local i_y = instance.y
            if math.abs(x - i_x) < world.block_size and math.abs(i_y - y) < world.block_size then
                return instance
            end
        end
    end
    return nil
end

function enemy:kill(instance)
    if instance then
        self.sounds.dead:stop()
        self.sounds.dead:setPosition(instance.x / 400, instance.y / 400, 0)
        self.sounds.dead:play()
        instance:stop()
        instance.dead = true
    end
end

return enemy