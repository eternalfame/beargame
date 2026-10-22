---@type BaseActor
local BaseActor = require('entities.baseActor')
---@type pointer
local pointer = require('systems.pointer')

---@class Hero
local Hero = setmetatable({}, { __index = BaseActor })
Hero.__index = Hero

function Hero.new()
    local self = BaseActor.new()
    setmetatable(self, Hero)

    self.image = love.graphics.newImage("img/hero.png")
    self.find_time = 0
    self:init()

    return self
end

function Hero:stop()
    BaseActor.stop(self)
    pointer:unset()
end

function Hero:setTarget(goal)
    local t = os.clock()
    BaseActor.setTarget(self, goal)
    self.find_time = os.clock() - t
end

return Hero
