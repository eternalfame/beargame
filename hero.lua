local hero = {
    x=nil,
    y=nil,
    path = {},
    image = love.graphics.newImage("img/hero.png"),
    frame = 0,
    valign = 't', -- also 'b'
    align = 'r', -- also 'l'
    orient = 'h',
    frames = {},
    goal = {
        x = nil,
        y = nil
    },
    new_goal = {
        x = nil,
        y = nil
    },
    del = 1,
    dead = false,
    opacity = 255,
}

require('globals')
local a_star = require('a_star')
local world = require('world')
local table = require('ext_table')
local pointer = require('pointer')

function hero:currentFrame()
    return self.frames[self.orient][self.frame]
end


function hero:init()
    self.del = 8
    local t_img = self.image
    t_img:setFilter("nearest", "linear")
    self.tile_count = (t_img:getWidth() * 3) / t_img:getHeight()
    for j, letter in pairs({'h', 'b', 't'}) do
        self.frames[letter] = {}
        for i = 0, self.tile_count - 1 do
            self.frames[letter][i] = love.graphics.newQuad(i * t_size, (j-1) * t_size, t_size, t_size, t_img:getWidth(), t_img:getHeight())
        end
    end

    self.model = love.graphics.newCanvas(world.block_size, world.block_size)
end

function hero:place(ol_x, ol_y)
    self.x = ol_x
    self.y = ol_y
end

function hero:setTarget(goal)
--    table.clear(self.goal)
    if not (self.goal.x and self.goal.y) then
        self.new_goal.x = goal.x
        self.new_goal.y = goal.y
        self.goal.x = goal.x
        self.goal.y = goal.y
        self:find()
    end
    if self.goal ~= goal then
        self.new_goal.x = goal.x
        self.new_goal.y = goal.y
    end
end

function hero:find()
    if not self.dead then
        table.clear(self.path)

        local self_node = self:getNode()

        if self_node and self.goal.x and self.goal.y then
            self.path = a_star:find({
                x = self_node.x * world.block_size,
                y = self_node.y * world.block_size
            }, self.goal)
            if not self.path[self_node] and self == hero then
                if self.x < self.goal.x then
                    self:setAlign('r')
                elseif self.x > self.goal.x then
                    self:setAlign('l')
                end
                if self.y < self.goal.y then
                    self:setVAlign('b')
                elseif self.y > self.goal.y then
                    self:setVAlign('t')
                end
            end
        end
    end
end

function hero:getNode()
    local function_x, function_y

    function_x = self.align == 'r' and m_floor or m_ceil
    function_y = self.valign == 't' and m_ceil or m_floor

    local hero_node = nodes:get(
        function_x(self.x / world.block_size),
        function_y(self.y / world.block_size)
    )

    return hero_node
end

function hero:nextFrame()
    self.frame = (self.frame) % (self.tile_count - 1) + 1
    self:updateFrame()
end

function hero:setFrame(frame)
    self.frame = frame
    self:updateFrame()
end

function hero:setAlign(align)
    self.orient = 'h'
    if self.align ~= align then
        self.align = align
    end
end

function hero:setVAlign(valign)
    self.orient = valign
    if self.valign ~= valign then
        self.valign = valign
    end
end

function hero:stop()
    self.new_goal.x = nil
    self.new_goal.y = nil
    if self == hero then
        pointer:unset()
    end
end

function hero:updateFrame()
    love.graphics.setCanvas(self.model)
    love.graphics.clear()
    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(255, 255, 255, self.opacity)
    if self.align == 'r' then
        love.graphics.draw(self.image, self:currentFrame(), 0, 0, 0, world.block_size/t_size, world.block_size/t_size)
    else
        love.graphics.draw(self.image, self:currentFrame(), world.block_size, 0, 0, -world.block_size/t_size, world.block_size/t_size)
    end
    love.graphics.setCanvas()
end

function hero:process()
    if self == hero then
        love.audio.setPosition(self.x / 400, self.y / 400, 0)
    end

    if not self.dead then

        local self_node, node_x, node_y
        local function_x, function_y

        self_node = self:getNode()

        if self.path[self_node] then
            if self.frame % 7 == 0 then
                local step = love.audio.newSource("fx/step.ogg", "static")
                step:setVolume(0.025)
                step:setPosition(self.x / 400, self.y / 400, 0)
                step:play()
            end


            local next_node = self.path[self_node]

            if self_node.x < next_node.x then
                self:setAlign('r')
            elseif self_node.x > next_node.x then
                self:setAlign('l')
            elseif self_node.y < next_node.y then
                self:setVAlign('b')
            elseif self_node.y > next_node.y then
                self:setVAlign('t')
            end

            self.x = self.x + ((next_node.x - self_node.x) * world.block_size) / self.del
            self.y = self.y + ((next_node.y - self_node.y) * world.block_size) / self.del
            local cond1 = self.x - (next_node.x * world.block_size)
            local cond2 = self.y - (next_node.y * world.block_size)
            if cond1 == 0 and cond2 == 0 then
                if self.goal ~= self.new_goal then
                    self.goal.x = self.new_goal.x
                    self.goal.y = self.new_goal.y
                    self:find()
                end
            end

            self:nextFrame()
        else
            if self_node then
                self.x = self_node.x * world.block_size
                self.y = self_node.y * world.block_size
            end
            self.new_goal.x = nil
            self.new_goal.y = nil
            self.goal.x = self.new_goal.x
            self.goal.y = self.new_goal.y
            self:setFrame(0)
            self:stop()
    --        end
        end
    else
        -- постепенно уменьшается яркость
        self.opacity = check(self.opacity - 25, self.opacity, 0)
        self:updateFrame()
        if self.opacity == 0 then
            -- смерть — печальная штука
            table.clear(self)
--            self = nil
        end
    end
end

return hero