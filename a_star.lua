local a_star = {}

require('globals')
local world = require('world')
local table = require('ext_table')

local function cost_estimate(start, goal)
    --	local m_abs = math.abs
    -- for more diagonal movement
    return m_pow((m_abs(start.x - goal.x)), 2) + m_pow((m_abs(start.y - goal.y)), 2)
end


local function lowest_f_score(f_score, open)
    local low_s, low_n = 999999999, nil
    for i = 1, #open do
        local node = open[i]
        local score = f_score[node]
        if score < low_s then
            low_s, low_n = score, node
        end
    end
    return low_n
end

local function neighbor_nodes(_current)
    local c_x = _current.x
    local c_y = _current.y

    local array = {}
    local arr_size = #array

    if world.map[c_y] then
        local c_x1 = c_x + 1
        if walkable(world.map[c_y][c_x1]) then
            arr_size = arr_size + 1
            array[arr_size] = {
                x=c_x1,
                y=c_y
            }
        end

        local c_x2 = c_x - 1
        if walkable(world.map[c_y][c_x2]) then
            arr_size = arr_size + 1
            array[arr_size] = {
                x=c_x2,
                y=c_y
            }
        end
    end

    local c_y1 = c_y + 1
    if world.map[c_y1] then
        if walkable(world.map[c_y1][c_x]) then
            arr_size = arr_size + 1
            array[arr_size] = {
                x=c_x,
                y=c_y1
            }
        end
    end

    local c_y2 = c_y - 1
    if world.map[c_y2] then
        if walkable(world.map[c_y2][c_x]) then
            arr_size = arr_size + 1
            array[arr_size] = {
                x=c_x,
                y=c_y2
            }
        end
    end

    local _nodes = nodes:get_four(array, arr_size)
    return _nodes
end


local function reconstruct(map, goal, start)
    local map_two = {}
    local tempik = goal
    while start ~= tempik do
        map_two[map[tempik]] = tempik
        tempik = map[tempik]
    end
    map[tempik] = nil
    return map_two
end

function a_star:find(from, to)
    local b_s = world.block_size
    local round_func = self.align == 'r' and m_floor or m_ceil
    local start = nodes:get(round_func(from.x / b_s), round_func(from.y / b_s))
    local goal = nodes:get(m_floor(to.x / b_s), m_floor(to.y / b_s))
    if not goal then
        return {}
    end
    local closed = {}
    local open = {
        start
    }
    local map = {}
    local g_score = {}
    local f_score = {}

    g_score[start] = 0
    f_score[start] = g_score[start] + cost_estimate(start, goal)

    while #open > 0 do
        local current = lowest_f_score(f_score, open)
        if current == goal then
            return reconstruct(map, goal, start)
        end
        table.remove_node(open, current)
        closed[#closed+1] = current
        local neighbours = neighbor_nodes(current)
        for i = 1, 4 do
            local ngh = neighbours[i]
            if ngh then
                if table.not_in(closed, ngh) then
                    local ten_g_s = g_score[current]
                    if table.not_in(open, ngh) or ten_g_s < g_score[ngh] then
                        map[ngh] = current
                        g_score[ngh] = ten_g_s
                        f_score[ngh] = g_score[ngh] + cost_estimate(ngh, goal)
                        if table.not_in(open, ngh) then
                            -- table.insert(open, ngh)
                            open[#open+1] = ngh
                        end
                    end
                end
            end
        end
    end

    return {}
end

return a_star