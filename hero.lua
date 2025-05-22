local BaseActor = require('BaseActor')
local pointer = require('pointer')

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

return Hero