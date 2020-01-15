block_size = 48
t_size = 64

m_abs = math.abs
m_pow = math.pow
m_ceil = math.ceil
m_floor = math.floor

nodes = {
    nodes = {}
}
tiles = {}
t_quads = {}

dbug = ""

time_delta1 = 0

--olya = {}
--world = {}

TILE_TREE  = 0
TILE_GRASS = 1
TILE_GRASS2= 2
TILE_BLACK = 3
TILE_STONE = 4
TILE_PINE  = 5
TILE_HOUSE = 6
TILE_TREE2 = 7

STEP_TIME = 0.03

mouse_blocked = true
happyend = false
intro = true

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end