local DEFAULT_LANG = "ru"
local AVAILABLE = { "ru", "en" }
local SAVE_FILE = "lang.txt"

local Locale = {}

local current, strings

local function isAvailable(code)
    for _, c in ipairs(AVAILABLE) do
        if c == code then return true end
    end
    return false
end

local function load(code)
    strings = require("locale." .. code)
    current = code
end

---@param code string
function Locale.set(code)
    assert(isAvailable(code), "unknown language: " .. tostring(code))
    load(code)
    love.filesystem.write(SAVE_FILE, code)
end

---@return string
function Locale.get()
    return current
end

function Locale.list()
    local list = {}
    for _, code in ipairs(AVAILABLE) do
        local s = require("locale." .. code)
        list[#list + 1] = { code = code, name = (s.meta and s.meta.name) or code }
    end
    return list
end

---@param key string
---@return string
function Locale.t(key, ...)
    local v = strings
    for part in key:gmatch("[^.]+") do
        v = type(v) == "table" and v[part] or nil
    end
    if type(v) ~= "string" then
        print(("[locale] missing key '%s' (%s)"):format(key, current))
        return "!" .. key .. "!"
    end
    if select("#", ...) > 0 then
        return v:format(...)
    end
    return v
end

do
    local ok, saved = pcall(love.filesystem.read, SAVE_FILE)
    if ok and type(saved) == "string" then
        saved = saved:match("^%s*(%S+)")
    end
    load(isAvailable(saved) and saved or DEFAULT_LANG)
end

return Locale
