local config = require('config')
local util = require('core.util')

---@class Flash
local Flash = {}
Flash.__index = Flash

function Flash.new(x, y)
    local self = setmetatable({}, Flash)

    self.x = x
    self.y = y
    self.image = love.graphics.newImage("img/flash.png")
    self.image:setFilter("nearest", "linear")
    self.model = love.graphics.newCanvas(config.block_size, config.block_size)
    self.opacity = 1
    self.sounds = {
        hit = love.audio.newSource("fx/hit.ogg", "static")
    }
    self.sounds.hit:setVolume(0.25)
    self.sounds.hit:setPosition(self.x / config.audio_scale, self.y / config.audio_scale, 0)

    self:updateModel()
    return self
end

function Flash:process()
    self.opacity = util.clamp(self.opacity - 0.1, 0, self.opacity)
    self:updateModel()
end

function Flash:updateModel()
    self.model:renderTo(function ()
        love.graphics.clear()
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(255, 255, 255, self.opacity)
        love.graphics.draw(self.image, 0, 0, 0, config.block_size/config.t_size, config.block_size/config.t_size)
    end)
end

function Flash:isActive()
    return self.opacity ~= 0
end

return Flash