---@type BaseActor
local BaseActor = require('BaseActor')
---@type pointer
local pointer = require('pointer')

---@class Hero
local Hero = setmetatable({}, { __index = BaseActor })
Hero.__index = Hero

function Hero.new()
    local self = BaseActor.new()
    setmetatable(self, Hero)

    self.image = love.graphics.newImage("img/hero.png")
    self:init()

    return self
end

function Hero:stop()
    BaseActor.stop(self)
    pointer:unset()
end

function Hero:setTarget(goal)
    time_delta1 = os.clock()
    BaseActor.setTarget(self, goal)
    time_delta1 = os.clock() - time_delta1
end

return Hero