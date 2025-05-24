---@type BaseActor
local BaseActor = require('baseActor')

---@class Girl
local Girl = setmetatable({}, { __index = BaseActor })
Girl.__index = Girl

function Girl.new()
    local self = BaseActor.new()
    setmetatable(self, Girl)

    self.image = love.graphics.newImage("img/girl.png")
    self:init()

    return self
end

return Girl