require 'src/gamestate'
require 'src/input'

SCREEN_WIDTH = love.window.getWidth()
SCREEN_HEIGHT = love.window.getHeight()

function love.load()
  gamestate.init()
end

function love.quit()
  print('Quitting...')
end

love.update = gamestate.update
love.draw = gamestate.draw

love.keypressed = input.keypressed
love.keyreleased = input.keyreleased
