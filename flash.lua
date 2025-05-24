require('globals')

---@class Flash
local Flash = {}
Flash.__index = Flash

function Flash.new(x, y)
    local self = setmetatable({}, Flash)

    self.x = x
    self.y = y
    self.image = love.graphics.newImage("img/flash.png")
    self.image:setFilter("nearest", "linear")
    self.model = love.graphics.newCanvas(block_size, block_size)
    self.opacity = 1
    self.sounds = {
        hit = love.audio.newSource("fx/hit.ogg", "static")
    }
    self.sounds.hit:setVolume(0.5)
    self.sounds.hit:setPosition(self.x / 400, self.y / 400, 0)

    self:updateModel()
    return self
end

function Flash:process()
    self.opacity = clamp(self.opacity - 0.1, self.opacity, 0)
    self:updateModel()
end

function Flash:updateModel()
    self.model:renderTo(function ()
        love.graphics.clear()
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(255, 255, 255, self.opacity)
        love.graphics.draw(self.image, 0, 0, 0, block_size/t_size, block_size/t_size)
    end)
end

function Flash:isActive()
    return self.opacity ~= 0
end

return Flash