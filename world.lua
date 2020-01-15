local world = {}

require('globals')
local table = require('ext_table')

function world:init()
    self.x = 0
    self.y = 0
    self.generated = false
    self.width = 200
    self.height = 200
    self.block_size = block_size
    self.enemy_spawns = {}
    self.r = 255
    self.g = 255
    self.b = 255
    --    self.spawn_x = 0
--    self.spawn_y = 0
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

function world:generate()

    self.generated = false
    self:flush_map()

--    local filename = self.x .. "_" .. self.y .. ".map"

--    if not love.filesystem.exists(filename) then
    local _x1 = love.math.random(world.width - world.width / 4, world.width - 5)
    local _y1 = check(m_abs(world.height * love.math.random(0, 1) - love.math.random(world.height / 3)), world.height - 8, 16)


    self.map[_y1 - 1][_x1] = TILE_GROUND
    self.map[_y1 - 2][_x1] = TILE_GROUND
    self.map[_y1 - 3][_x1] = TILE_GROUND
    self.map[_y1 - 4][_x1] = TILE_GROUND
    self.map[_y1 - 5][_x1] = TILE_GROUND
    self.map[_y1 - 6][_x1] = TILE_GROUND
    self.map[_y1 - 7][_x1] = TILE_GROUND
    self.spawn_x = _x1
    self.spawn_y = _y1 - 7

    local c = 0

    local _x2 = love.math.random(self.width / 4)
    local _y2 = m_abs(self.height * love.math.random(0, 1) - love.math.random(self.height / 3))

    self.house_x = _x2
    self.house_y = _y2

    self.map[_y2][_x2] = TILE_HOUSE

    while _x1 ~= _x2 or _y1 ~= _y2 do
        self.map[_y1][_x1] = TILE_GROUND

        c = c + 1
        if c % 30 ~= 0 then
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
            self.map[_y1][_x1] = 1
            _y1 = _y1 + sign(_y2 - _y1)
        end

        _x1 = check(_x1, self.width, 1)
        _y1 = check(_y1, self.height, 1)
    end

    for _ = 1, love.math.random(50, 100) do
        local r_y = love.math.random(1, self.height)
        local r_x = love.math.random(1, self.width)
        if self.map[r_y] and self.map[r_y][r_x] ~= TILE_HOUSE then
            if walkable(self.map[r_y][r_x]) then
                for __y = -1, 1 do
                    for __x = -1, 1 do
                        if self.map[r_y + __y] and not walkable(self.map[r_y + __y][r_x + __x]) then
                            self.map[r_y + __y][r_x + __x] = TILE_GROUND
                        end
                    end
                end
                self.map[r_y][r_x] = TILE_STONE
            end
        end
    end

    for i = 1, love.math.random(13, 18) do
        local e_x = love.math.random(world.width / 4, world.width - world.width / 3)
        local e_y
        while e_y == nil do
            local temp = love.math.random(world.height)
            if self.map[temp] and walkable(self.map[temp][e_x]) then
                e_y = temp
            end
        end
        self.enemy_spawns[i] = {
            x = e_x,
            y = e_y
        }
    end

--        local string_for_save = self:generate_savecode()
--        love.filesystem.write(filename, string_for_save)
--    else
--        love.filesystem.load(filename)()
--    end

    nodes:generate_nodes()

    --	for i = 1, #(enemy.all) do
    --		enemy.all[i].path = nil
    --		enemy.all[i] = nil
    --    end
    --
    --	for i = 1, math.random(4) do
    --		enemy.all[i] = {}
    --		enemy.all[i].path = {}
    --		enemy:place(i)
    --    end

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