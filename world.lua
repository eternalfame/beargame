---@class world
local world = {}
---@class nodes
local nodes = { nodes = {} }

require('globals')
local table = require('ext_table')

local sqrt = math.sqrt
local random = love.math.random

-- Tile constants
local TILE_TREE  = 0
local TILE_GRASS = 1
local TILE_GRASS2= 2
local TILE_BLACK = 3
local TILE_STONE = 4
local TILE_PINE  = 5
local TILE_HOUSE = 6
local TILE_TREE2 = 7

-- Random tile aliases
setmetatable(_G, {
    __index = function(_, k)
        if k == 'TILE_GROUND' then
            local ground = {TILE_GRASS, TILE_GRASS2}
            return ground[random(#ground)]
        elseif k == 'TILE_FOREST' then
            local forest = {TILE_TREE, TILE_TREE2, TILE_PINE}
            return forest[random(#forest)]
        end
    end
})

local UNWALKABLE = {
    [TILE_TREE] = true,
    [TILE_TREE2] = true,
    [TILE_STONE] = true,
    [TILE_BLACK] = true,
    [TILE_PINE] = true,
    [TILE_HOUSE] = true
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
    self.width = 200
    self.height = 200
    self.block_size = block_size
    self.enemy_spawns = {}
    self.r, self.g, self.b = 1, 1, 1
    self.nodes = nodes
end

function world:flush_map()
    self.map = {}
    for y = 1, self.height do
        local row = {}
        for x = 1, self.width do
            row[x] = TILE_FOREST
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
    local init_y = clamp(m_abs(self.height * random(0, 1) - random(self.height / 3)), self.height - 8, 16)

    local goal_x = random(self.width / 4)
    local goal_y = m_abs(self.height * random(0, 1) - random(math.floor(self.height / 3)))

    self.house_x, self.house_y = goal_x, goal_y
    self.map[goal_y][goal_x] = TILE_HOUSE

    local x, y = init_x, init_y
    local complexity = 120
    local step = 0

    while x ~= goal_x or y ~= goal_y do
        self.map[y][x] = TILE_GROUND
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
            self.map[y][x] = TILE_GRASS
            y = y + sign(goal_y - y)
        end

        x = clamp(x, self.width, 1)
        y = clamp(y, self.height, 1)
    end

    -- Stones
    for _ = 1, random(50, 100) do
        local sx, sy
        repeat
            sx = random(1, self.width)
            sy = random(1, self.height)
        until self:walkable(sx, sy)

        for dy = -1, 1 do
            for dx = -1, 1 do
                local nx, ny = sx + dx, sy + dy
                if self.map[ny] and not self:walkable(nx, ny) then
                    self.map[ny][nx] = TILE_GROUND
                end
            end
        end
        self.map[sy][sx] = TILE_STONE
    end

    -- Hero spawn
    for i = 1, 7 do
        self.map[init_y - i][init_x] = TILE_GROUND
    end
    self.spawn_x = init_x
    self.spawn_y = init_y - 7

    -- Enemies
    for i = 1, random(13, 18) do
        local ex = random(math.floor(self.width / 4), self.width - math.floor(self.width / 3))
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

function world:generate_savecode()
    local str = "local world = require('world') world.map = {\n"
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

return world