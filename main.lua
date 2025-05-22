local mainTimer = 0
local mainTimer2 = 0

local camera = require('camera')
local world = require('world')
local hero = require('hero')
local girl = deepcopy(require('girl'))
local enemies = require('enemy')
local pointer = require('pointer')
local flashes = {}
local flash = require('flash')
local conversation = require('conversation')

local scr_h = 0
local scr_w = 0
local scr_h_b = 0
local scr_w_b = 0

local max_c_x = 0
local max_c_y = 0

local table = require('ext_table')
local music = require('music')

function load_tiles()
    local t_img = love.graphics.newImage("img/tiles.png")
    t_img:setFilter("nearest", "linear")
    local tile_count = t_img:getWidth() / t_img:getHeight()
    -- wall
    for i = 0, tile_count do
        t_quads[i] = love.graphics.newQuad(i * t_size, 0, t_size, t_size, t_img:getWidth(), t_img:getHeight())
    end

    local t_count = (scr_w_b + 1) * (scr_h_b + 1)

    return love.graphics.newSpriteBatch(t_img, t_count)
end

function update_tiles(layer, tileset)
    tileset:clear()
    local _i = m_floor(camera.y / world.block_size)
    local _j = m_floor(camera.x / world.block_size)
    local __i = _i + scr_h_b
    local __j = _j + scr_w_b
    local _k = world.block_size / t_size

    for i = _i, __i, 1 do
        local y1 = i * world.block_size
        for j = _j, __j, 1 do
            local x1 = j * world.block_size
            if layer == 0 then
                if world.map[i] and world.map[i][j] ~= nil then
                    tileset:add(t_quads[world.map[i][j]], x1, y1, 0, _k, _k)
                end
            elseif layer == 3 then
                -- grid
                tileset:add(t_quads[TILE_GRID], x1, y1, 0, _k, _k)
            end
        end
    end
end

function clamp(x, max, min)
    if x > max then
        x = max
    end
    if x < min then
        x = min
    end
    return x
end

function sign(x)
    if x ~= 0 then
        return math.floor(x / math.abs(x))
    else
        return 0
    end
end

function love.load()
    love.window.setVSync( 1 )

    happyend = false
    if intro then
        mouse_blocked = true
    else
        mouse_blocked = false
    end

    conversation:setQueue({
        {
            timer = 1
        },
        {
            timer = 1,
            func = function ()
                -- walk slowly in intro
                hero:setSpeed(1.0)
                girl:setSpeed(1.0)
                if world:walkable(girl.x / world.block_size, girl.y / world.block_size - 2) then
                    girl:setTarget({x = girl.x, y = girl.y - world.block_size * 2})
                else
                    girl:setTarget({x = girl.x, y = girl.y - world.block_size * 3})
                end
                hero:setTarget({x = hero.x, y = hero.y + world.block_size})
            end
        },
        {
            timer = 5,
            text = "Медведь, я искала тебя, чтобы отдать тебе приглашение на мой день рождения!",
            talker = girl,
            height = 4
        },
        {
            timer = 3,
            text = "Ого, я и не думал, что ты меня пригласишь!",
            talker = hero,
            height = 2
        },
        {
            timer = 2,
            text = "Как же я могла тебя не пригласить??",
            talker = girl,
            height = 2
        },
        {
            timer = 1,
            text = "...",
            talker = girl,
            height = 1
        },
        {
            timer = 2,
            text = "Знаешь, теперь у нас большие проблемы",
            talker = girl,
            height = 2
        },
        {
            timer = 3,
            text = "Этот лес населен кошмарами. Без твоей помощи я не вернусь домой",
            talker = girl,
            height = 3
        },
        {
            timer = 2,
            text = "Для меня это не проблема. Пойдем",
            talker = hero,
            height = 2
        },
        {
            timer = 1,
        },
        {
            timer = 3,
            text = "(Я двигаюсь с помощью левой кнопки мыши. Стреляю с помощью правой)",
            talker = hero,
            height = 3
        },
        {
            timer = 0,
            func = function ()
                hero:setSpeed(6.0)  -- change for debug purposes
                girl:setSpeed(6.0)
                intro = false
                mouse_blocked = false
                conversation:clearQueue()
            end
        }
    })

    conversation:setWinString({
        talker = hero,
        timer = 20,
        height = 4,
        text = "C ДНЁМ РОЖДЕНИЯ!!!\nСлушай музыку\nили нажми ESC, чтобы выйти\nR, чтобы начать заново"
    })

    conversation:setLoseString({
        talker = hero,
        timer = 20,
        height = 3,
        text = "ОЧЕНЬ ПЛОХОЙ КОНЕЦ :(\nНажми ESC, чтобы выйти\nR, чтобы начать заново"
    })

    music:stop_second()
    music:play_first()

    love.keyboard.setKeyRepeat(false)

    love.graphics.setBackgroundColor(155, 155, 155)

    world:init()
    world:generate()

    scr_h = love.graphics.getHeight()
    scr_w = love.graphics.getWidth()
    scr_h_b = m_ceil(scr_h / world.block_size)
    scr_w_b = m_ceil(scr_w / world.block_size)

    hero:init()
    if not table.not_empty(girl) then
        girl = deepcopy(require('girl'))
    end
    girl:init()
    enemies:init()

    for _, enemy in ipairs(enemies) do
        if table.not_empty(enemy) then
            enemy:init()
        end
    end

    hero:updateFrame()

    pointer:init()

    hero:place(world.spawn_x * world.block_size, world.spawn_y * world.block_size)

    for _, enemy in ipairs(enemies) do
        if table.not_empty(enemy) then
            enemy:place(
                world.enemy_spawns[_].x * world.block_size,
                world.enemy_spawns[_].y * world.block_size
            )
        end
    end

    max_c_x = (world.width + 1) * world.block_size - scr_w
    max_c_y = (world.height + 1) * world.block_size - scr_h

    local f = love.graphics.newFont("FreeSans.ttf", 16)
    love.graphics.setFont(f)

    local tileset = load_tiles()

    girl:place(hero.x, hero.y + world.block_size * 7)

    table.clear(camera.layers)

    camera:newLayer(0, function()
        love.graphics.setColor(world.r, world.g, world.b, 1)
        update_tiles(0, tileset)
        love.graphics.draw(tileset)
    end)

    camera:newLayer(1, function ()
        if pointer:exists() then
            love.graphics.setColor(255, 255, 255, 1)
            love.graphics.draw(pointer.model, pointer.x, pointer.y)
        end
    end)

    camera:newLayer(2, function()
        love.graphics.setColor(255, 255, 255, 1)

        if table.not_empty(girl) then
            love.graphics.draw(girl.model, girl.x, girl.y)
        end

        for _, enemy in ipairs(enemies) do
            if table.length(enemy) > 0 then
                love.graphics.draw(enemy.model, enemy.x, enemy.y)
            end
        end

        love.graphics.draw(hero.model, hero.x, hero.y)

        for _, flash in ipairs(flashes) do
            if table.length(flash) > 0 then
                love.graphics.draw(flash.model, flash.x, flash.y)
            end
        end

        local text = conversation:getCurrent()

        if text and text.talker then
            local text_x = text.talker.x + world.block_size/2 - 16*7
            local text_y = text.talker.y - 16 * text.height or 1 * 1.5
            local text_w = 16 * 14
            local font_size = 19

            love.graphics.setColor(0, 0, 0, 0.5)
            love.graphics.rectangle("fill", text_x - 10, text_y, text_w + 20, text.height * font_size + 10)
            love.graphics.setColor(255, 255, 255, 1)
            love.graphics.printf(text.text, text_x, text_y, text_w, "center")
        end
    end)
end

function love.update(dt)
    mainTimer = mainTimer + dt

    if not intro then
        if mainTimer >= STEP_TIME then
            if table.not_empty(girl) then
                if world:distance(girl, {x=world.house_x * world.block_size, y=world.house_y * world.block_size})
                        < 4 * world.block_size then
                    world.r = clamp(world.r - 10, world.r, 5)
                    mouse_blocked = true
                    happyend = true

                    conversation:printWin()

                    music:stop_first()
                    music:play_second()
                    local target_x, target_y
                    local __pairs = {
                        {x = -1, y =  0},
                        {x =  1, y =  0},
                        {x =  0, y =  1},
                        {x =  0, y = -1}
                    }
                    for _, _c in pairs(__pairs) do
                        local _x = world.house_x + _c.x
                        local _y = world.house_y + _c.y
                        if world:walkable(_x, _y) then
                            target_x = _x * world.block_size
                            target_y = _y * world.block_size
                        end
                    end
                    girl:setSpeed(4.0)
                    hero:setSpeed(2.0)
                    girl:setTarget({
                        x = target_x,
                        y = target_y
                    })
                    if world:distance(hero, girl) <= world.block_size * 2 then
                        hero:stop()
                    else
                        hero:setTarget({
                            x = girl.x,
                            y = girl.y
                        })
                    end
                elseif not happyend and world:distance(girl, hero) > 3 * world.block_size then
                    girl:setTarget({
                        x = hero.x,
                        y = hero.y
                    })
                elseif not happyend then
                    girl:stop()
                end
                girl:process()
            else
                world.g = world.g - 0.1
                world.b = world.b - 0.1
                mouse_blocked = true
                hero:stop()
            end
            hero:process()

            if not happyend then
                for _, enemy in ipairs(enemies) do
                    if table.not_empty(enemy) and table.not_empty(girl) then
                        local distance_to_trigger_enemy = 25  -- todo: must depend on screen resolution
                        local distance_to_kill = 1
                        local distance_to_girl = world:distance(enemy, girl)

                        if distance_to_girl < distance_to_trigger_enemy * world.block_size then
                            enemy:setTarget({x=girl.x, y=girl.y})
                            if distance_to_girl < distance_to_kill * world.block_size then
                                conversation:printLose()
                                enemies:kill(girl)
                            end
                        end
                        enemy:process()
                    else
                        enemy = nil
                    end
                end
            end
            for _, flash in ipairs(flashes) do
                if table.length(flash) > 0 then
                    flash:process()
                else
                    flash = nil
                end
            end
        end
    else -- if intro
        if mainTimer >= STEP_TIME then
            hero:process()
            girl:process()
        end
        conversation:process(dt)
    end
    if mainTimer >= STEP_TIME then
        mainTimer2 = mainTimer2 + mainTimer
        mainTimer = mainTimer - STEP_TIME
        if mainTimer2 >= STEP_TIME*2 then
            mainTimer2 = mainTimer2 - STEP_TIME*2
        end
    end
    local cam_x = clamp(hero.x + world.block_size / 2  - scr_w / 2, max_c_x, world.block_size)
    local cam_y = clamp(hero.y + world.block_size / 2 - scr_h / 2, max_c_y, world.block_size)
    camera:setPosition(cam_x, cam_y)

end

function love.draw()
    camera:draw()
    if debug then
        local s_format = string.format
        love.graphics.print("FPS: " .. love.timer.getFPS(), 2, 2)
        love.graphics.print(hero.x .. "; " .. hero.y .. '; ' .. hero.align .. ' ' .. hero.valign, 2, 50)
        love.graphics.print(s_format("time_to_find: %.5f\n", time_delta1), 2, 74)
        love.graphics.print('Памяти засрано: ' .. collectgarbage('count') .. 'kB', 2, 122)
        love.graphics.print(mainTimer, 2, 146)
        love.graphics.print(mainTimer2, 2, 170)
        love.graphics.print(tostring(conversation.queue), 2, 194)

    end
end

function love.keypressed(key, _, isrepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == 'r' and not intro then
        for _, enemy in ipairs(enemies) do
            table.clear(enemy)
            enemy = nil
        end
        love.load()
    elseif key == 'd' then
        debug = true
    end
end

function love.mousepressed(x, y, button)
    if not mouse_blocked then
        local block_size = world.block_size

        local press_location_x = camera.x + x
        local press_location_y = camera.y + y

        local temp_x = math.floor(press_location_x / block_size) * block_size
        local temp_y = math.floor(press_location_y / block_size) * block_size

        if button == 1 then
            pointer:set(temp_x, temp_y)
            hero:setTarget({
                x = pointer.x,
                y = pointer.y
            })
        elseif button == 3 then
            hero:stop()
        elseif button == 2 then
            flash.sounds.hit:play()
            table.insert(flashes, flash:create(press_location_x - block_size / 2, press_location_y - block_size / 2))
            enemies:kill(enemies:get(press_location_x, press_location_y))
        end

    elseif intro then
        conversation:skip()
    end
end