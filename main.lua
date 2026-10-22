local State = require('core.state')

State.install({
    "update", "draw",
    "keypressed", "keyreleased",
    "mousepressed", "mousereleased", "mousemoved",
    "textinput",
})

function love.load()
    State.register("menu", require('states.menu'))
    State.register("game", require('states.game'))
    State.switch("menu")
end
