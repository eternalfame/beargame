---@class a_star
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

    local coords_to_get = {}
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not (dx == 0 and dy == 0) then
                table.insert(coords_to_get, {x = c_x + dx, y = c_y + dy})
            end
        end
    end
    -- returns only walkable nodes
    return world.nodes:get_many(coords_to_get)
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
    local start = world:get_node_by_real_coords(from.x, from.y)
    local goal = world:get_node_by_real_coords(to.x, to.y)
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