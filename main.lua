Object = require "libraries/classic"
lume = require "libraries/lume"
vector = require "libraries/vector"
anim8 = require("libraries/anim8/anim8")

require "src/game/globals"
require "src/game/Game"
require "src/game/Map"
require "src/game/Background"
inputs = require "src/game/Inputs"
require "src/game/Tiles"
require "src/player/Player"

function love.load()
    current_state = Game()
    if current_state.load then
        current_state:load()
    end
end

function love.update(dt)
    if current_state.update then
        current_state:update(dt)
    end
end

function love.draw()
    if current_state.draw then
        current_state:draw()
    end
end

function love.keypressed(key, scancode, isrepeat)
    if current_state.keypressed then
        current_state:keypressed(key, scancode, isrepeat)
    end
end

function love.joystickadded(joystick)
    if current_state.joystickadded then
        current_state:joystickadded(joystick)
    end
end