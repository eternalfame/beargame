block_size = 48  -- responsible for zoom level
t_size = 64 -- responsible for texture size

debug = false

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

function clamp(x, max, min)
    return (x < min) and min or (x > max and max or x)
end

function sign(x)
    return x == 0 and 0 or x / math.abs(x)
end

printf = function(s,...)
    return io.write(s:format(...))
end -- function

function printtable(_table, indent)

    indent = indent or 0;

    local keys = {};

    for k in pairs(_table) do
        keys[#keys+1] = k;
        table.sort(keys, function(a, b)
            local ta, tb = type(a), type(b);
            if (ta ~= tb) then
                return ta < tb;
            else
                return a < b;
            end
        end);
    end

    print(string.rep('  ', indent)..'{');
    indent = indent + 1;
    for k, v in pairs(_table) do

        local key = k;
        if (type(key) == 'string') then
            if not (string.match(key, '^[A-Za-z_][0-9A-Za-z_]*$')) then
                key = "['"..key.."']";
            end
        elseif (type(key) == 'number') then
            key = "["..key.."]";
        end

        if (type(v) == 'table') then
            if (next(v)) then
                printf("%s%s =", string.rep('  ', indent), tostring(key));
                printtable(v, indent);
            else
                printf("%s%s = {},", string.rep('  ', indent), tostring(key));
            end
        elseif (type(v) == 'string') then
            printf("%s%s = %s,", string.rep('  ', indent), tostring(key), "'"..v.."'");
        else
            printf("%s%s = %s,", string.rep('  ', indent), tostring(key), tostring(v));
        end
    end
    indent = indent - 1;
    print(string.rep('  ', indent)..'}');
end