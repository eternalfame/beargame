---@type BaseActor
local BaseActor = require('entities.baseActor')
local config = require('config')

---@class Enemy : BaseActor
local Enemy = setmetatable({}, { __index = BaseActor })
Enemy.__index = Enemy

function Enemy.new()
    local self = BaseActor.new()
    setmetatable(self, Enemy)

    self.image = love.graphics.newImage("img/inverted.png")
    self:init()
    self:setSpeed(config.speed.enemy)

    return self
end

return Enemy