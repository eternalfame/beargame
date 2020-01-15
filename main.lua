camera = {}
camera.layers = {}
camera.x = 0
camera.y = 0
local debug = true

local mainTimer = 0
local mainTimer2 = 0

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

setmetatable(_G, {__index =
function(t, k)
    if k == 'TILE_GROUND' then
        local arr = {TILE_GRASS, TILE_GRASS2}
        return arr[love.math.random(#arr)]
    elseif k == 'TILE_FOREST' then
        local arr = {TILE_TREE, TILE_TREE2, TILE_PINE}
        return arr[love.math.random(#arr)]
    end
end
})

local UNWALKABLE = {
    TILE_TREE,
    TILE_TREE2,
    TILE_STONE,
    TILE_BLACK,
    TILE_PINE,
    TILE_HOUSE
}

function walkable(tile)
    if tile ~= nil and table.not_in(UNWALKABLE, tile) then
        return true
    end
    return false
end

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
--	if layer == 0 then
--		tileset:add(t_quads[3], 0, exit_y, 0, _k, _k)
--		tileset:add(t_quads[3], exit_x, exit_y, 0, _k, _k)
--	end
end

function camera:set()
	  love.graphics.push()
	  love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
  	love.graphics.pop()
end

function camera:newLayer(index, func)
	table.insert(self.layers, {draw = func, index = index})
	table.sort(self.layers, function(a, b) return a.index < b.index end)
end

function camera:draw()
	for _, v in pairs(self.layers) do
		self:set()
		v.draw()
		self:unset()
	end
end

function camera:move(dx, dy)
	self.x = self.x + (dx or 0)
	self.y = self.y + (dy or 0)
end

function camera:setPosition(x, y)
    self.x = x or self.x
	self.y = y or self.y
end

function nodes:generate_nodes()
    table.clear(self.nodes)
	for i = 1, world.height, 1 do
		for j = 1, world.width, 1 do
			if walkable(world.map[i][j]) then
				local temp = {
					x = j,
					y = i
				}
				table.insert(self.nodes, temp)
			end
		end
	end
end

function nodes:get(x, y)
    for _, node in ipairs(self.nodes) do
        if node.x == x and node.y == y then
            return node
        end
    end

	return nil
end

function nodes:get_four(array, _array)
	local nodes = {}
	for _, node in ipairs(self.nodes) do
		for i = 1, _array do
			if node.x == array[i].x and node.y == array[i].y then
				table.insert(nodes, node)
			end
		end
		if #nodes == _array then
			return nodes
		end
	end
	return nodes
end



function check(x, max, min)
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
                hero.del = 48
                girl.del = 48
                if walkable(world.map[girl.y / world.block_size - 2][girl.x / world.block_size]) then
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
                hero.del = 8  -- change for debug purposes
                girl.del = 8
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
--    love.window.setFullscreen(true, "desktop")

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
        love.graphics.setColor(world.r, world.g, world.b, 255)
        update_tiles(0, tileset)
		love.graphics.draw(tileset)
	end)

	camera:newLayer(1, function ()
        if pointer:exists() then
            love.graphics.setColor(255, 255, 255, 255)
            love.graphics.draw(pointer.model, pointer.x, pointer.y)
        end
	end)

    camera:newLayer(2, function()
		love.graphics.setColor(255, 255, 255, 255)

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
            love.graphics.printf(
                text.text,
                text.talker.x + world.block_size/2 - 16*7,
                text.talker.y - 16 * text.height or 1 * 1.5 ,
                32 * 7,
                "center"
            )
        end
	end)

--	camera:newLayer(3, function()
--		update_tiles(3, tileset)
--		love.graphics.draw(tileset)
--	end)

end

function love.update(dt)
    mainTimer = mainTimer + dt

    if not intro then
        if mainTimer >= STEP_TIME then
            if table.not_empty(girl) then
                if m_abs(girl.x - world.house_x * world.block_size) +
                        m_abs(girl.y - world.house_y * world.block_size) < 15 * world.block_size then
                    world.r = check (world.r - 10, world.r, 5)
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
                        if world.map[_y] and walkable(world.map[_y][_x]) then
                            target_x = _x * world.block_size
                            target_y = _y * world.block_size
                        end
                    end
                    girl.del = 12
                    hero.del = 24
                    girl:setTarget({
                        x = target_x,
                        y = target_y
                    })
                    if math.abs(hero.x - girl.x) + math.abs(hero.y - girl.y) <= world.block_size * 3 then
                        hero:stop()
                    else
                        hero:setTarget({
                            x = girl.x,
                            y = girl.y
                        })
                    end
                elseif m_abs(girl.x - hero.x) + m_abs(girl.y - hero.y) > 5 * world.block_size then
                    girl:setTarget({
                        x = hero.x,
                        y = hero.y
                    })
                else
                    girl:stop()
                end
                girl:process()
            end
            hero:process()
            for _, enemy in ipairs(enemies) do
                if table.not_empty(enemy) and table.not_empty(girl) then
                    distance_to_trigger_enemy = 25  -- todo: must be dependent on screen resolution

                    if m_abs(enemy.x - girl.x) + m_abs(enemy.y - girl.y) < distance_to_trigger_enemy * world.block_size then
                        enemy:setTarget(girl)
                        if m_abs(enemy.x - girl.x) + m_abs(enemy.y - girl.y) < world.block_size then
                            mouse_blocked = true
                            conversation:printLose()
                            enemies:kill(girl)
                            world.g = check(world.g - 10, world.g, 5)
                            world.b = check(world.b - 10, world.b, 5)
                        end
                    end
                    enemy:process()
                else
                    enemy = nil
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
	local cam_x = check(hero.x + world.block_size / 2  - scr_w / 2, max_c_x, world.block_size)
	local cam_y = check(hero.y + world.block_size / 2 - scr_h / 2, max_c_y, world.block_size)
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

function love.keypressed(key, isrepeat)
--	if isrepeat and keyTimer > 0.15 or not isrepeat then
--		if key == "up" or key == "w" then
--			hero:move(0, -1)
--		elseif key == "left" or key == "a" then
--			hero:move(-1, 0)
--		elseif key == "down" or key == "s" then
--			hero:move(0, 1)
--		elseif key == "right" or key == "d" then
--			hero:move(1, 0)
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
--		if isrepeat then
--			keyTimer = 0
--		end
--	end
end

function love.mousepressed(x, y, button)
    if not mouse_blocked then
        local temp_x = math.floor((camera.x + x) / world.block_size) * world.block_size
        local temp_y = math.floor((camera.y + y) / world.block_size) * world.block_size

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
            table.insert(flashes, flash:create(temp_x, temp_y))
            enemies:kill(enemies:get(temp_x, temp_y))
        end

    elseif intro then
        conversation:skip()
    end
end