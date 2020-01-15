require 'love.audio'
require 'love.math'
require 'love.filesystem'

local music = {
    files = {
        love.audio.newSource("music/game_1.it", "static")
    }
}

music.files[love.math.random(1, #(music.files))]:play()