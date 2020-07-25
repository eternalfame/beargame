require('globals')
local world = require('world')

local flash = {
    x = nil,
    y = nil,
    image = love.graphics.newImage("img/flash.png"),
    model = nil,
    opacity = 1,
    sounds = {
        hit = love.audio.newSource("fx/hit.ogg", "static")
    }
}

function flash:create(x, y)
    self.x = x
    self.y = y
    self.image:setFilter("nearest", "linear")
    self.sounds.hit:setVolume(0.5)
    self.sounds.hit:setPosition(self.x / 400, self.y / 400, 0)

    self.model = love.graphics.newCanvas(world.block_size, world.block_size)
    self:updateModel()
    return deepcopy(self)
end

function flash:process()
    self.opacity = clamp(self.opacity - 0.1, self.opacity, 0)
    self:updateModel()
    if self.opacity == 0 then
        table.clear(self)
    end
end

function flash:updateModel()
    self.model:renderTo(function ()
        love.graphics.clear()
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(255, 255, 255, self.opacity)
        love.graphics.draw(self.image, 0, 0, 0, world.block_size/t_size, world.block_size/t_size)
    end)
end

return flash