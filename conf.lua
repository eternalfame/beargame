function love.conf(t)
	t.window.vsync = false
    t.console = true
    love.filesystem.setIdentity("dynamic", true)
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
end