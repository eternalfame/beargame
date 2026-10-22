local Enemy = require('entities.enemy')
local world = require('systems.world')
local table = require('core.ext_table')
local config = require('config')

---@class EnemyManager
local EnemyManager = {}
EnemyManager.__index = EnemyManager

EnemyManager.sounds = {
    dead = love.audio.newSource("fx/death.ogg", "static")
}
EnemyManager.sounds.dead:setVolume(0.25)

function EnemyManager.new()
    local self = setmetatable({}, EnemyManager)
    ---@type Enemy[]
    self.instances = {}
    self:spawn()
    return self
end

function EnemyManager:spawn()
    local bs = world.block_size
    for _, pos in ipairs(world.enemy_spawns) do
        local enemy = Enemy.new()
        enemy:place(pos.x * bs, pos.y * bs)
        table.insert(self.instances, enemy)
    end
end

---@param actor BaseActor|nil
function EnemyManager:kill(actor)
    if actor and not actor.dead then
        self.sounds.dead:stop()
        self.sounds.dead:setPosition(actor.x / config.audio_scale, actor.y / config.audio_scale, 0)
        self.sounds.dead:play()

        actor:stop()
        actor.dead = true
    end
end

---@return Enemy|nil
function EnemyManager:get(x, y)
    for i = #self.instances, 1, -1 do
        local enemy = self.instances[i]

        if enemy and not enemy.dead then
            local dx = math.abs(x - enemy.x)
            local dy = math.abs(y - enemy.y)
            if dx < world.block_size and dy < world.block_size then
                return enemy
            end
        else
            table.remove(self.instances, i)
        end
    end

    return nil
end

function EnemyManager:draw()
    for _, enemy in ipairs(self.instances) do
        love.graphics.draw(enemy.model, enemy.x, enemy.y)
    end
end

---@param girl BaseActor|nil
---@return boolean killed_girl true if the girl was caught this frame
function EnemyManager:update(girl)
    local killed_girl = false
    local trigger = config.enemy.trigger_distance * world.block_size
    local kill = config.enemy.kill_distance * world.block_size

    for i = #self.instances, 1, -1 do
        local enemy = self.instances[i]

        if not enemy.dead and girl and not girl.dead then
            local distance_to_girl = world:distance(enemy, girl)
            if distance_to_girl < trigger then
                enemy:setTarget({ x = girl.x, y = girl.y })
                if distance_to_girl < kill then
                    self:kill(girl)
                    killed_girl = true
                end
            end
        end

        if not enemy:process() then
            table.remove(self.instances, i)
        end
    end

    return killed_girl
end

return EnemyManager