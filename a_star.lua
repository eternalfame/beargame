local a_star = {}

require('globals')
local world = require('world')
local table = require('ext_table')

local INF = 1/0

local function cost_estimate(start, goal)
    return math.max(math.abs(start.x - goal.x), math.abs(start.y - goal.y))
end

local function real_distance(start, goal)
    return world:distance(start, goal)
end


local function lowest_f_score(f_score, open)
    local low_s, low_n = INF, nil
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

    for x = c_x-1, c_x+1 do
        for y = c_y-1, c_y+1 do
            if not (x == c_x and y == c_y) then
                if world:walkable(x, y) then
                    arr_size = arr_size + 1
                    array[arr_size] = {x=x,y=y}
                end
            end
        end
    end
    local _nodes = world.nodes:get_many(array, arr_size)
    return _nodes
end

local function reconstruct(map, goal, start)
    local map_two = {}
    local temp = goal
    while start ~= temp do
        map_two[map[temp]] = temp
        temp = map[temp]
    end
    map[temp] = nil
    return map_two
end

function a_star:find(from, to)
    local b_s = world.block_size
    local start = world.nodes:get(m_floor(from.x / b_s), m_floor(from.y / b_s))
    local goal = world.nodes:get(m_floor(to.x / b_s), m_floor(to.y / b_s))
    if not goal then
        return {}
    end
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
        local neighbours = neighbor_nodes(current)
        for i = 1, #neighbours do
            local ngh = neighbours[i]
            if ngh then
                local ten_g_s = g_score[current] + real_distance(current, ngh)
                if not g_score[ngh] or ten_g_s < g_score[ngh] then
                    map[ngh] = current
                    g_score[ngh] = ten_g_s
                    f_score[ngh] = g_score[ngh] + cost_estimate(ngh, goal)
                    if table.not_in(open, ngh) then
                        open[#open+1] = ngh
                    end
                end
            end
        end
    end

    return {}
end

return a_star