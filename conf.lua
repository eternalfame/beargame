function love.conf(t)
	t.window.vsync = true
    t.console = true
    love.filesystem.setIdentity("dynamic", true)
    t.window.fullscreen = true
    t.window.fullscreentype = "desktop"
    t.modules.physics = false
end