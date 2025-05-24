require('globals')
---@type BaseActor
local BaseActor = require('baseActor')
local world = require('world')
local table = require('ext_table')

---@class Enemy
local Enemy = {}
Enemy.__index = Enemy

Enemy.sounds = {
    dead = love.audio.newSource("fx/death.ogg", "static")
}

---@type BaseActor[]
Enemy.instances = {}  -- store all enemy instances here

function Enemy.new()
    local self = setmetatable({}, Enemy)
    self.instances = {}
    self:init()
    return self
end

function Enemy:init()
    self.sounds.dead:setVolume(0.5)

    for _, spawn in ipairs(world.enemy_spawns) do
        ---@type BaseActor
        local enemy = BaseActor:new()
        enemy.image = love.graphics.newImage("img/inverted.png")
        enemy:init()
        enemy:setSpeed(6.0)
        enemy:place(spawn.x, spawn.y)
        table.insert(self.instances, enemy)
    end
end

function Enemy:get(x, y)
    ---@param instance BaseActor
    for _, instance in ipairs(self.instances) do
        if instance and not instance.dead then
            local dx = math.abs(x - instance.x)
            local dy = math.abs(y - instance.y)
            if dx < world.block_size and dy < world.block_size then
                return instance
            end
        else
            table.remove_node(self.instances, instance)
        end
    end
    return nil
end

---@param instance BaseActor
function Enemy:kill(instance)
    if instance and not instance.dead then
        self.sounds.dead:stop()
        self.sounds.dead:setPosition(instance.x / 400, instance.y / 400, 0)
        self.sounds.dead:play()
        instance:stop()
        instance.dead = true
    end
end

return Enemy