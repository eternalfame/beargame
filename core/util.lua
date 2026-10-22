local util = {}

util.abs   = math.abs
util.ceil  = math.ceil
util.floor = math.floor

function util.clamp(x, min, max)
    return (x < min) and min or (x > max and max or x)
end

function util.sign(x)
    return x == 0 and 0 or x / math.abs(x)
end

function util.printf(s, ...)
    return io.write(s:format(...))
end

function util.printtable(_table, indent)
    indent = indent or 0

    local keys = {}
    for k in pairs(_table) do
        keys[#keys + 1] = k
        table.sort(keys, function(a, b)
            local ta, tb = type(a), type(b)
            if ta ~= tb then
                return ta < tb
            else
                return a < b
            end
        end)
    end

    print(string.rep('  ', indent) .. '{')
    indent = indent + 1
    for k, v in pairs(_table) do
        local key = k
        if type(key) == 'string' then
            if not string.match(key, '^[A-Za-z_][0-9A-Za-z_]*$') then
                key = "['" .. key .. "']"
            end
        elseif type(key) == 'number' then
            key = "[" .. key .. "]"
        end

        if type(v) == 'table' then
            if next(v) then
                util.printf("%s%s =", string.rep('  ', indent), tostring(key))
                util.printtable(v, indent)
            else
                util.printf("%s%s = {},", string.rep('  ', indent), tostring(key))
            end
        elseif type(v) == 'string' then
            util.printf("%s%s = %s,", string.rep('  ', indent), tostring(key), "'" .. v .. "'")
        else
            util.printf("%s%s = %s,", string.rep('  ', indent), tostring(key), tostring(v))
        end
    end
    indent = indent - 1
    print(string.rep('  ', indent) .. '}')
end

return util
