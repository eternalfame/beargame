require('globals')
local hero = require('hero')

-- наследуем девочку от героя
local girl = deepcopy(hero)
girl.image = love.graphics.newImage("img/girl.png")

return girl