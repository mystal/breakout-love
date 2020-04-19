local Gamestate = require 'lib/hump.gamestate'

local input = require 'src/input'
local menustate = require 'src/menustate'

SCREEN_WIDTH = love.window.getWidth()
SCREEN_HEIGHT = love.window.getHeight()

function love.load()
  Gamestate.push(menustate)
end

function love.quit()
  print('Quitting...')
end

love.update = Gamestate.update
love.draw = Gamestate.draw

love.keypressed = input.keypressed
love.keyreleased = input.keyreleased
