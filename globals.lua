block_size = 48  -- responsible for zoom level
t_size = 64 -- responsible for texture size

debug = true

m_abs = math.abs
m_pow = math.pow
m_ceil = math.ceil
m_floor = math.floor

tiles = {}
t_quads = {}

time_delta1 = 0

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