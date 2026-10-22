local State = require('core.state')
local L = require('locale')

local menu = {}

local FONT_FILE = "fonts/FreeSans.ttf"
local BUTTON_W, BUTTON_H, GAP = 320, 56, 16

local fonts
local screen = "main"  -- "main" | "language"
local buttons = {}
local selected = 1

local function startGame()
    State.switch("game", { intro = true })
end

local function buildButtons()
    if screen == "language" then
        local list = {}
        local current = L.get()
        for _, lang in ipairs(L.list()) do
            list[#list + 1] = {
                label = lang.name,
                active = (lang.code == current),
                action = function()
                    L.set(lang.code)
                    menu.open("main", 2)
                end,
            }
        end
        list[#list + 1] = {
            label = L.t("menu.back"),
            action = function() menu.open("main", 2) end,
        }
        return list
    end

    return {
        { label = L.t("menu.start"),    action = startGame },
        { label = L.t("menu.language"), action = function() menu.open("language") end },
        { label = L.t("menu.quit"),     action = function() love.event.quit() end },
    }
end

function menu.open(name, index)
    screen = name
    buttons = buildButtons()
    selected = index or 1
    if name == "language" and not index then
        for i, b in ipairs(buttons) do
            if b.active then selected = i end
        end
    end
end

local function buttonRect(i)
    local w, h = love.graphics.getDimensions()
    local total = #buttons * BUTTON_H + (#buttons - 1) * GAP
    local top = h * 0.5 - total / 2 + 40
    return (w - BUTTON_W) / 2, top + (i - 1) * (BUTTON_H + GAP), BUTTON_W, BUTTON_H
end

local function buttonAt(mx, my)
    for i = 1, #buttons do
        local x, y, w, h = buttonRect(i)
        if mx >= x and mx <= x + w and my >= y and my <= y + h then
            return i
        end
    end
end

function menu.enter()
    fonts = fonts or {
        title  = love.graphics.newFont(FONT_FILE, 48),
        button = love.graphics.newFont(FONT_FILE, 26),
    }
    love.graphics.setBackgroundColor(0.1, 0.1, 0.13)
    menu.open("main")
end

function menu.draw()
    local w = love.graphics.getWidth()

    -- заголовок
    local _, first_y = buttonRect(1)
    love.graphics.setFont(fonts.title)
    love.graphics.setColor(1, 1, 1)
    local heading = (screen == "language") and L.t("menu.language") or L.t("menu.title")
    love.graphics.printf(heading, 0, first_y - fonts.title:getHeight() - 40, w, "center")

    -- кнопки
    love.graphics.setFont(fonts.button)
    for i, b in ipairs(buttons) do
        local x, y, bw, bh = buttonRect(i)

        if i == selected then
            love.graphics.setColor(0.35, 0.35, 0.55)
        else
            love.graphics.setColor(0.2, 0.2, 0.26)
        end
        love.graphics.rectangle("fill", x, y, bw, bh, 8, 8)

        if b.active then  -- текущий язык
            love.graphics.setColor(0.9, 0.75, 0.3)
            love.graphics.setLineWidth(3)
            love.graphics.rectangle("line", x, y, bw, bh, 8, 8)
            love.graphics.setLineWidth(1)
        end

        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(b.label, x, y + (bh - fonts.button:getHeight()) / 2, bw, "center")
    end
end

function menu.mousemoved(x, y)
    local i = buttonAt(x, y)
    if i then selected = i end
end

function menu.mousepressed(x, y, button)
    if button ~= 1 then return end
    local i = buttonAt(x, y)
    if i then
        selected = i
        buttons[i].action()
    end
end

function menu.keypressed(key)
    if key == "up" or key == "w" then
        selected = (selected - 2) % #buttons + 1
    elseif key == "down" or key == "s" then
        selected = selected % #buttons + 1
    elseif key == "return" or key == "kpenter" or key == "space" then
        buttons[selected].action()
    elseif key == "escape" then
        if screen == "language" then
            menu.open("main", 2)
        else
            love.event.quit()
        end
    end
end

return menu
