---@class pointer
local pointer = {
    x=nil,
    y=nil,
}

local config = require('config')

function pointer:init()
    self.model = love.graphics.newCanvas(config.block_size, config.block_size)

    self.model:renderTo(function ()
        love.graphics.clear()
        love.graphics.setBlendMode('alpha', 'premultiplied')
		love.graphics.setColor(255, 255, 0, 0.5)
		love.graphics.rectangle('fill', 0, 0, config.block_size, config.block_size)
    end)
end

function pointer:exists()
    return self.x and self.y
end

function pointer:set(x, y)
    self.x = x
    self.y = y
end

function pointer:unset()
    self.x = nil
    self.y = nil
end

return pointer