local music = {
    files = {
        love.audio.newSource("music/game_1.it", "static"),
		love.audio.newSource("music/game_2.ogg", "static")
    }
}

function music:play_first()
    self.files[1]:play()
end

function music:play_second()
    self.files[2]:play()
end

function music:stop_first()
    self.files[1]:stop()
end

function music:stop_second()
    self.files[2]:stop()
end

return music