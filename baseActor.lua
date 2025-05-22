local BaseActor = {}
BaseActor.__index = BaseActor

local a_star = require('a_star')
local world = require('world')
local table = require('ext_table')
require('globals')

function BaseActor.new()
    local self = setmetatable({}, BaseActor)

    self.x = nil
    self.y = nil
    self.node = nil
    self.path = {}
    self.image = love.graphics.newImage("img/hero.png")
    self.frame = 0
    self.valign = 't'
    self.align = 'r'
    self.orient = 'h'
    self.frames = {}
    self.goal = { x = nil, y = nil }
    self.new_goal = { x = nil, y = nil }
    self.del = 1
    self.dead = false
    self.opacity = 1

    self:init()
    return self
end

function BaseActor:init()
    self:setSpeed(6)
    self.image:setFilter("nearest", "linear")
    self.tile_count = (self.image:getWidth() * 3) / self.image:getHeight()

    for j, letter in ipairs({'h', 'b', 't'}) do
        self.frames[letter] = {}
        for i = 0, self.tile_count - 1 do
            self.frames[letter][i] = love.graphics.newQuad(
                i * t_size, (j - 1) * t_size, t_size, t_size,
                self.image:getWidth(), self.image:getHeight()
            )
        end
    end

    self.model = love.graphics.newCanvas(world.block_size, world.block_size)
end

function BaseActor:setSpeed(speed)
    self.del = 48.0 / speed
end

function BaseActor:currentFrame()
    return self.frames[self.orient][self.frame]
end

function BaseActor:place(x, y)
    self.x = x
    self.y = y
    self.node = world.nodes:get(x / world.block_size, y / world.block_size)
end

function BaseActor:setTarget(goal)
    if not (self.goal.x and self.goal.y) then
        self.new_goal.x, self.new_goal.y = goal.x, goal.y
        self.goal.x, self.goal.y = goal.x, goal.y
        self:find()
    elseif self.goal.x ~= goal.x or self.goal.y ~= goal.y then
        self.new_goal.x, self.new_goal.y = goal.x, goal.y
    end
end

function BaseActor:find()
    if not self.dead then
        table.clear(self.path)

        local node = self:getNode()
        if node and self.goal.x and self.goal.y then
            self.path = a_star:find({
                x = node.x * world.block_size,
                y = node.y * world.block_size
            }, self.goal)

            if not self.path[node] then
                if self.x < self.goal.x then self:setAlign('r')
                elseif self.x > self.goal.x then self:setAlign('l') end

                if self.y < self.goal.y then self:setVAlign('b')
                elseif self.y > self.goal.y then self:setVAlign('t') end
            end
        end
    end
end

function BaseActor:getNode()
    return self.node
end

function BaseActor:nextFrame()
    self.frame = (self.frame % (self.tile_count - 1)) + 1
    self:updateFrame()
end

function BaseActor:setFrame(frame)
    self.frame = frame
    self:updateFrame()
end

function BaseActor:setAlign(align)
    self.orient = 'h'
    self.align = align
end

function BaseActor:setVAlign(valign)
    self.orient = valign
    self.valign = valign
end

function BaseActor:stop()
    self.new_goal.x, self.new_goal.y = nil, nil
end

function BaseActor:updateFrame()
    self.model:renderTo(function ()
        love.graphics.clear()
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(1, 1, 1, self.opacity)
        local sx = world.block_size / t_size
        if self.align == 'r' then
            love.graphics.draw(self.image, self:currentFrame(), 0, 0, 0, sx, sx)
        else
            love.graphics.draw(self.image, self:currentFrame(), world.block_size, 0, 0, -sx, sx)
        end
    end)
end

function BaseActor:process()
    local bs = world.block_size
    local abs = math.abs

    if not self.dead then
        local node = self:getNode()
        local next_node = self.path[node]

        if next_node then
            if self.frame % 7 == 0 then
                self.step_sound = self.step_sound or love.audio.newSource("fx/step.ogg", "static")
                self.step_sound:setVolume(0.025)
                self.step_sound:setPosition(self.x / 400, self.y / 400, 0)
                self.step_sound:play()
            end

            -- Alignment logic
            if node.x ~= next_node.x then
                self:setAlign(node.x < next_node.x and 'r' or 'l')
            elseif node.y ~= next_node.y then
                self:setVAlign(node.y < next_node.y and 'b' or 't')
            end

            -- Move towards next node
            local delta = bs / self.del
            self.x = self.x + (next_node.x - node.x) * delta
            self.y = self.y + (next_node.y - node.y) * delta

            -- Snap if close enough
            local dx = abs(self.x - next_node.x * bs)
            local dy = abs(self.y - next_node.y * bs)
            if dx < delta and dy < delta then
                self.node = next_node
                self.x = next_node.x * bs
                self.y = next_node.y * bs

                -- If the goal changed during the movement, recalculate the path
                if self.goal.x ~= self.new_goal.x or self.goal.y ~= self.new_goal.y then
                    self.goal.x = self.new_goal.x
                    self.goal.y = self.new_goal.y
                    self:find()
                end
            end

            self:nextFrame()
        else
            if node then
                self.x, self.y = node.x * bs, node.y * bs
            end
            self.goal.x, self.goal.y = nil, nil
            self.new_goal.x, self.new_goal.y = nil, nil
            self:setFrame(0)
            self:stop()
        end
    else
        if self.opacity == 0 then
            return
        end
        self.opacity = clamp(self.opacity - 0.1, self.opacity, 0)
        self:updateFrame()
    end
end

return BaseActor