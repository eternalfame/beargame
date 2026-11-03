local game = {}

local mainTimer = 0
local mainTimer2 = 0

local camera = require('systems.camera')
local world = require('systems.world')
local Hero = require('entities.hero')
local Girl = require('entities.girl')
local EnemyManager = require('entities.enemyManager')
local pointer = require('systems.pointer')
local Flash = require('systems.flash')
local Conversation = require('systems.conversation')
local Dialogue = require('systems.dialogue')
local L = require('locale')
local music = require('systems.music')
local config = require('config')
local util = require('core.util')
local table = require('core.ext_table')

local m_floor = util.floor
local clamp = util.clamp

local scripts = {
    intro   = require('scripts.intro'),
    endings = require('scripts.endings'),
}

---@type Flash[]
local flashes = {}

local scr_w, scr_h = 0, 0
local max_c_x, max_c_y = 0, 0

local intro = false
local happyend = false
local mouse_blocked = true
local show_debug = false

---@type Hero|nil
local hero = nil
---@type Girl|nil
local girl = nil
---@type EnemyManager|nil
local enemy_manager = nil
---@type Conversation
local conversation = Conversation.new()

---@param opts { intro: boolean }|nil
function game.enter(opts)
    if opts and opts.intro ~= nil then
        intro = opts.intro
    end

    happyend = false
    mouse_blocked = intro

    music:stop_second()
    music:play_first()

    -- love.math.setRandomSeed(1)
    love.keyboard.setKeyRepeat(false)

    local bg = config.color.background
    love.graphics.setBackgroundColor(bg[1], bg[2], bg[3])

    world:init()
    world:generate()

    scr_w = love.graphics.getWidth()
    scr_h = love.graphics.getHeight()

    hero = Hero.new()
    girl = Girl.new()
    enemy_manager = EnemyManager.new()

    hero:updateFrame()
    pointer:init()

    hero:place(world.spawn_x * world.block_size, world.spawn_y * world.block_size)

    local ctx = {
        actors = { hero = hero, girl = girl },
        on_finish = function()
            intro = false
            mouse_blocked = false
            conversation:clearQueue()
        end,
    }

    conversation:setQueue(Dialogue.build(scripts.intro, ctx))
    conversation:setWinString(Dialogue.entry(scripts.endings.win, ctx, "win"))
    conversation:setLoseString(Dialogue.entry(scripts.endings.lose, ctx, "lose"))

    max_c_x = (world.width + 1) * world.block_size - scr_w
    max_c_y = (world.height + 1) * world.block_size - scr_h

    local f = love.graphics.newFont("fonts/FreeSans.ttf", 16)
    love.graphics.setFont(f)

    world:loadTiles()

    girl:place(hero.x, hero.y + world.block_size * 7)

    table.clear(camera.layers)

    camera:newLayer(0, function()
        world:drawTiles(camera)
    end)

    camera:newLayer(1, function ()
        if pointer:exists() then
            love.graphics.setColor(255, 255, 255, 1)
            love.graphics.draw(pointer.model, pointer.x, pointer.y)
        end
    end)

    camera:newLayer(2, function()
        love.graphics.setColor(255, 255, 255, 1)

        if girl then
            love.graphics.draw(girl.model, girl.x, girl.y)
        end

        if enemy_manager then
            enemy_manager:draw()
        end

        love.graphics.draw(hero.model, hero.x, hero.y)

        for _, flash in ipairs(flashes) do
            if flash and flash:isActive() then
                love.graphics.draw(flash.model, flash.x, flash.y)
            end
        end

        conversation:drawCurrent()
    end)
end

function game.update(dt)
    love.audio.setPosition(hero.x / config.audio_scale, hero.y / config.audio_scale, 0)

    mainTimer = mainTimer + dt
    while mainTimer >= config.step_time do
        mainTimer = mainTimer - config.step_time
        mainTimer2 = mainTimer2 + config.step_time
        if mainTimer2 >= config.step_time * 2 then mainTimer2 = mainTimer2 - config.step_time * 2 end

        if not intro then
            if happyend then
                world.r = clamp(world.r - 10, 5, world.r)

                local target_x, target_y
                local offsets = {
                    {x =  0, y =  1},
                    {x =  1, y =  0},
                    {x = -1, y =  0},
                    {x =  0, y = -1},
                }
                for _, c in ipairs(offsets) do
                    local hx = world.house_x + c.x
                    local hy = world.house_y + c.y
                    if world:walkable(hx, hy) then
                        target_x = hx * world.block_size
                        target_y = hy * world.block_size
                        break
                    end
                end
                girl:setSpeed(config.speed.happyend_girl)
                hero:setSpeed(config.speed.happyend_hero)
                girl:setTarget({ x = target_x, y = target_y })
                if world:distance(hero, girl) <= world.block_size * 2 then
                    hero:stop()
                else
                    hero:setTarget({ x = girl.x, y = girl.y })
                end
            end

            if not girl.dead then
                if not happyend then
                    if world:anyNearHouse({ hero, girl }) then
                        happyend = true
                        conversation:printWin()
                        music:stop_first()
                        music:play_second()
                        mouse_blocked = true
                    elseif world:distance(girl, hero) > 3 * world.block_size then
                        girl:setTarget({
                            x = hero.x,
                            y = hero.y
                        })
                    else
                        girl:stop()
                    end
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
                if enemy_manager:update(girl) then
                    conversation:printLose()
                end
            end

            for i = #flashes, 1, -1 do
                local flash = flashes[i]

                if not flash or not flash:isActive() then
                    table.remove(flashes, i)
                else
                    flash:process()
                end
            end
        else -- if intro
            hero:process()
            girl:process()
            conversation:process(dt)
        end
    end

    local cam_x = m_floor(clamp(hero.x + world.block_size / 2  - scr_w / 2, world.block_size, max_c_x))
    local cam_y = m_floor(clamp(hero.y + world.block_size / 2 - scr_h / 2, world.block_size, max_c_y))
    camera:setPosition(cam_x, cam_y)
end

function game.draw()
    camera:draw()
    if show_debug then
        local s_format = string.format
        love.graphics.print("FPS: " .. love.timer.getFPS(), 2, 2)
        love.graphics.print(s_format("A-star calculation time: %.2f", hero.find_time or 0), 2, 26)
        love.graphics.print(hero.x .. "; " .. hero.y .. '; ' .. hero.align .. ' ' .. hero.valign, 2, 50)
        love.graphics.print(L.t("debug.memory", collectgarbage('count')), 2, 122)
    end
end

function game.keypressed(key, _, isrepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == 'r' and not intro then
        game.enter()
    elseif key == 'd' then
        show_debug = not show_debug
    end
end

function game.mousepressed(x, y, button)
    if not mouse_blocked then
        local block_size = world.block_size

        local press_location_x = camera.x + x
        local press_location_y = camera.y + y

        local temp_x = m_floor(press_location_x / block_size) * block_size
        local temp_y = m_floor(press_location_y / block_size) * block_size

        if button == 1 then
            pointer:set(temp_x, temp_y)
            hero:setTarget({
                x = pointer.x,
                y = pointer.y
            })
        elseif button == 3 then
            hero:stop()
        elseif button == 2 then
            local _x, _y = press_location_x - block_size / 2, press_location_y - block_size / 2

            local flash = Flash.new(_x, _y)
            flash.sounds.hit:play()
            table.insert(flashes, flash)
            enemy_manager:kill(enemy_manager:get(_x, _y))
        end

    elseif intro then
        conversation:skip()
    end
end

return game
