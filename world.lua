local world = {}

require('globals')
local table = require('ext_table')

local nodes = { -- represent walkable zones
    nodes = {}
}

local TILE_TREE  = 0
local TILE_GRASS = 1
local TILE_GRASS2= 2
local TILE_BLACK = 3
local TILE_STONE = 4
local TILE_PINE  = 5
local TILE_HOUSE = 6
local TILE_TREE2 = 7

setmetatable(_G, {
    __index = function(t, k)
        if k == 'TILE_GROUND' then
            local arr = {TILE_GRASS, TILE_GRASS2}
            return arr[love.math.random(#arr)]
        elseif k == 'TILE_FOREST' then
            local arr = {TILE_TREE, TILE_TREE2, TILE_PINE}
            return arr[love.math.random(#arr)]
        end
    end
})

local UNWALKABLE = {
    TILE_TREE,
    TILE_TREE2,
    TILE_STONE,
    TILE_BLACK,
    TILE_PINE,
    TILE_HOUSE
}

function walkable(tile)
    if tile ~= nil and table.not_in(UNWALKABLE, tile) then
        return true
    end
    return false
end

function nodes:generate_nodes()
    table.clear(self.nodes)
    for i = 1, world.height, 1 do
        for j = 1, world.width, 1 do
            if world:walkable(j, i) then
                table.insert(self.nodes, {x=j, y=i})
            end
        end
    end
end

function nodes:get(x, y)
    for _, node in ipairs(self.nodes) do
        if node.x == x and node.y == y then
            return node
        end
    end

    return nil
end

function nodes:get_many(array, _array)
    local nodes = {}
    for _, node in ipairs(self.nodes) do
        for i = 1, _array do
            if node.x == array[i].x and node.y == array[i].y then
                table.insert(nodes, node)
            end
        end
        if #nodes == _array then
            return nodes
        end
    end
    return nodes
end

function world:init()
    self.x = 0
    self.y = 0
    self.generated = false
    self.width = 200
    self.height = 200
    self.block_size = block_size
    self.enemy_spawns = {}
    self.r = 1
    self.g = 1
    self.b = 1

    self.nodes = nodes
end

function world:flush_map()
    if self.map ~= nil then
        table.clear(self.map)
    else
        self.map = {}
    end

    for i = 1, self.height, 1 do
        self.map[i] = {}
        for j = 1, self.width, 1 do
            self.map[i][j] = TILE_FOREST
        end
    end
end

function world:get_node(x, y)
    if not self.map[y] then
        return nil
    end
    return self.map[y][x]
end

function world:walkable(x, y)
    return walkable(self:get_node(x, y))
end

function world:distance(node1, node2)
    return math.sqrt(m_pow(node1.x - node2.x, 2) + m_pow(node1.y - node2.y, 2))
end

function world:generate()
    self.generated = false
    self:flush_map()

    -- initial hero location
    local _x1 = love.math.random(world.width - world.width / 4, world.width - 5)
    local _y1 = clamp(m_abs(world.height * love.math.random(0, 1) - love.math.random(world.height / 3)), world.height - 8, 16)

    local initial_x = _x1
    local initial_y = _y1

    local c = 0

    -- endgame destination location
    local _x2 = love.math.random(self.width / 4)
    local _y2 = m_abs(self.height * love.math.random(0, 1) - love.math.random(self.height / 3))

    self.house_x = _x2
    self.house_y = _y2

    self.map[_y2][_x2] = TILE_HOUSE

    -- generate path from hero to destination
    local world_complexity_level = 120
    while _x1 ~= _x2 or _y1 ~= _y2 do
        self.map[_y1][_x1] = TILE_GROUND

        c = c + 1
        if c % world_complexity_level ~= 0 then
            local _r = love.math.random(4)
            if _r == 1 then
                _y1 = _y1 + 1
            elseif _r == 2 then
                _x1 = _x1 + 1
            elseif _r == 3 then
                _y1 = _y1 - 1
            elseif _r == 4 then
                _x1 = _x1 - 1
            end
        else
            _x1 = _x1 + sign(_x2 - _x1)
            self.map[_y1][_x1] = TILE_GRASS
            _y1 = _y1 + sign(_y2 - _y1)
        end

        _x1 = clamp(_x1, self.width, 1)
        _y1 = clamp(_y1, self.height, 1)
    end

    -- place stones
    local stones_count = love.math.random(50, 100)
    for _ = 1, stones_count do
        local r_y = nil
        local r_x = nil
        while not self:walkable(r_x, r_y) do
            r_y = love.math.random(1, self.height)
            r_x = love.math.random(1, self.width)
        end
        -- make zone around stone walkable
        for __y = -1, 1 do
            for __x = -1, 1 do
                if self.map[r_y + __y] and not walkable(self.map[r_y + __y][r_x + __x]) then
                    self.map[r_y + __y][r_x + __x] = TILE_GROUND
                end
            end
        end
        self.map[r_y][r_x] = TILE_STONE
    end

    -- place hero at initial position and make zone around walkable
    _x1 = initial_x
    _y1 = initial_y

    self.map[_y1 - 1][_x1] = TILE_GROUND
    self.map[_y1 - 2][_x1] = TILE_GROUND
    self.map[_y1 - 3][_x1] = TILE_GROUND
    self.map[_y1 - 4][_x1] = TILE_GROUND
    self.map[_y1 - 5][_x1] = TILE_GROUND
    self.map[_y1 - 6][_x1] = TILE_GROUND
    self.map[_y1 - 7][_x1] = TILE_GROUND
    self.spawn_x = _x1
    self.spawn_y = _y1 - 7

    -- place enemies
    for i = 1, love.math.random(13, 18) do
        local e_x = love.math.random(world.width / 4, world.width - world.width / 3)
        local e_y
        while e_y == nil do
            local temp = love.math.random(world.height)
            if self:walkable(e_x, temp) then
                e_y = temp
            end
        end
        self.enemy_spawns[i] = {x=e_x, y=e_y}
    end

    self.nodes:generate_nodes()
    self.generated = true
end

function world:generate_savecode()
    local str = "local world = require('world') world.map = {\n"
    local map = self.map
    for x = 1, #map do
        str = str .. "\t{ "
        for y = 1, #map[1] do
            str = str .. tostring(map[x][y])
            if y < #map[1] then
                str = str.. ", "
            end
        end
        str = str .. " },\n"
    end
    str = str .. " \n}"

    return str
end

return world