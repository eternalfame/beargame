---@class camera
local camera = {}
camera.layers = {}
camera.x = 0
camera.y = 0

function camera:set()
    love.graphics.push()
    love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
    love.graphics.pop()
end

function camera:newLayer(index, func)
    table.insert(self.layers, {draw = func, index = index})
    table.sort(self.layers, function(a, b) return a.index < b.index end)
end

function camera:draw()
    for _, v in pairs(self.layers) do
        self:set()
        v.draw()
        self:unset()
    end
end

function camera:move(dx, dy)
    self.x = self.x + (dx or 0)
    self.y = self.y + (dy or 0)
end

function camera:setPosition(x, y)
    self.x = x or self.x
    self.y = y or self.y
end

return camera