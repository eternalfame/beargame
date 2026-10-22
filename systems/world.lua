---@class world
local world = {}
---@class nodes
local nodes = { nodes = {} }

local config = require('config')
local util = require('core.util')
local table = require('core.ext_table')

local sqrt = math.sqrt
local random = love.math.random
local m_abs, m_ceil, m_floor = util.abs, util.ceil, util.floor
local clamp, sign = util.clamp, util.sign

local T = config.tiles

local GROUND = { T.GRASS, T.GRASS2 }
local FOREST = { T.TREE, T.TREE2, T.PINE }

function world.randomGround()
    return GROUND[random(#GROUND)]
end

function world.randomForest()
    return FOREST[random(#FOREST)]
end

local UNWALKABLE = {
    [T.TREE]  = true,
    [T.TREE2] = true,
    [T.STONE] = true,
    [T.BLACK] = true,
    [T.PINE]  = true,
    [T.HOUSE] = true,
}

-- Walkable check
local function walkable(tile)
    return tile ~= nil and not UNWALKABLE[tile]
end

function nodes:generate_nodes(world)
    table.clear(self.nodes)
    for y = 1, world.height do
        for x = 1, world.width do
            if world:walkable(x, y) then
                self.nodes[x] = self.nodes[x] or {}
                self.nodes[x][y] = {x = x, y = y}
            end
        end
    end
end

function nodes:get(x, y)
    return self.nodes[x] and self.nodes[x][y]
end

function nodes:get_many(array)
    local result = {}
    for i = 1, #array do
        local pos = array[i]
        local n = self:get(pos.x, pos.y)
        if n then result[#result + 1] = n end
    end
    return result
end

function world:init()
    self.x, self.y = 0, 0
    self.generated = false
    self.width = config.world.width
    self.height = config.world.height
    self.block_size = config.block_size
    self.enemy_spawns = {}
    self.r, self.g, self.b = 1, 1, 1
    self.nodes = nodes
end

function world:flush_map()
    self.map = {}
    for y = 1, self.height do
        local row = {}
        for x = 1, self.width do
            row[x] = world.randomForest()
        end
        self.map[y] = row
    end
end

function world:get_node(x, y)
    return self.map[y] and self.map[y][x]
end

function world:walkable(x, y)
    return walkable(self:get_node(x, y))
end

function world:distance(a, b)
    local dx, dy = a.x - b.x, a.y - b.y
    return sqrt(dx * dx + dy * dy)
end

function world:get_node_by_real_coords(x, y)
    local b_s = self.block_size
    return self.nodes:get(m_floor(x / b_s), m_floor(y / b_s))
end

function world:generate()
    self.generated = false
    self:flush_map()

    local init_x = random(self.width - self.width / 4, self.width - 5)
    local init_y = clamp(m_abs(self.height * random(0, 1) - random(self.height / 3)), 16, self.height - 8)

    local goal_x = random(self.width / 4)
    local goal_y = clamp(m_abs(self.height * random(0, 1) - random(m_floor(self.height / 3))), 16, self.height - 8)

    self.house_x, self.house_y = goal_x, goal_y
    self.map[goal_y][goal_x] = T.HOUSE

    local x, y = init_x, init_y
    local complexity = config.world.complexity
    local step = 0

    while x ~= goal_x or y ~= goal_y do
        self.map[y][x] = world.randomGround()
        step = step + 1

        if step % complexity ~= 0 then
            -- Random movement
            local directions = {
                {x=0,  y=1},
                {x=1,  y=0},
                {x=0,  y=-1},
                {x=-1, y=0},
                {x=1,  y=1},
                {x=1,  y=-1},
                {x=-1,  y=1},
                {x=-1, y=-1}
            }
            local dir = directions[random(8)]
            x = x + dir.x
            y = y + dir.y
        else
            -- Goal directed movement
            x = x + sign(goal_x - x)
            self.map[y][x] = T.GRASS
            y = y + sign(goal_y - y)
        end

        x = clamp(x, 1, self.width)
        y = clamp(y, 1, self.height)
    end

    -- Stones
    for _ = 1, random(config.world.stones_min, config.world.stones_max) do
        local sx, sy
        repeat
            sx = random(1, self.width)
            sy = random(1, self.height)
        until self:walkable(sx, sy)

        for dy = -1, 1 do
            for dx = -1, 1 do
                local nx, ny = sx + dx, sy + dy
                if self.map[ny] and not self:walkable(nx, ny) then
                    self.map[ny][nx] = world.randomGround()
                end
            end
        end
        self.map[sy][sx] = T.STONE
    end

    -- Hero spawn
    for i = 1, 7 do
        self.map[init_y - i][init_x] = world.randomGround()
    end
    self.spawn_x = init_x
    self.spawn_y = init_y - 7

    -- Enemies
    for i = 1, random(config.world.enemies_min, config.world.enemies_max) do
        local ex = random(m_floor(self.width / 4), self.width - m_floor(self.width / 3))
        local ey
        repeat
            local temp = random(self.height)
            if self:walkable(ex, temp) then ey = temp end
        until ey
        self.enemy_spawns[i] = {x = ex, y = ey}
    end

    self.nodes:generate_nodes(self)
    self.generated = true
end

function world:loadTiles()
    local img = love.graphics.newImage("img/tiles.png")
    img:setFilter("nearest", "linear")

    self.tile_image = img
    self.t_quads = {}
    local tile_count = img:getWidth() / img:getHeight()
    for i = 0, tile_count do
        self.t_quads[i] = love.graphics.newQuad(
            i * config.t_size, 0, config.t_size, config.t_size,
            img:getWidth(), img:getHeight()
        )
    end

    self.screen_w_b = m_ceil(love.graphics.getWidth() / self.block_size)
    self.screen_h_b = m_ceil(love.graphics.getHeight() / self.block_size)
    self.tileset = love.graphics.newSpriteBatch(img, (self.screen_w_b + 1) * (self.screen_h_b + 1))
end

function world:drawTiles(camera)
    local tileset = self.tileset
    tileset:clear()

    local bs = self.block_size
    local scale = bs / config.t_size
    local i0 = m_floor(camera.y / bs)
    local j0 = m_floor(camera.x / bs)

    for i = i0, i0 + self.screen_h_b do
        local y1 = i * bs
        local row = self.map[i]
        if row then
            for j = j0, j0 + self.screen_w_b do
                if row[j] ~= nil then
                    tileset:add(self.t_quads[row[j]], j * bs, y1, 0, scale, scale)
                end
            end
        end
    end

    love.graphics.setColor(self.r, self.g, self.b, 1)
    love.graphics.draw(tileset)
end

function world:generate_savecode()
    local str = "local world = require('systems.world') world.map = {\n"
    for y = 1, #self.map do
        local row = self.map[y]
        str = str .. "\t{ "
        for x = 1, #row do
            str = str .. tostring(row[x])
            if x < #row then str = str .. ", " end
        end
        str = str .. " },\n"
    end
    return str .. " \n}"
end

function world:houseCenter()
    return {
        x = self.house_x * self.block_size,
        y = self.house_y * self.block_size,
    }
end

---@param actor { x: number, y: number }
---@param radius number|nil
function world:isNearHouse(actor, radius)
    return self:distance(actor, self:houseCenter()) < (radius or config.world.house_radius) * self.block_size
end

---@param actors { x: number, y: number }[]
function world:anyNearHouse(actors, radius)
    for _, actor in ipairs(actors) do
        if self:isNearHouse(actor, radius) then
            return true
        end
    end
    return false
end

return world
