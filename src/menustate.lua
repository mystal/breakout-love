local gamestate = require 'src/gamestate'
local input = require 'src/input'

menustate = {}

local MainMenu = {PLAY = 1, OPTIONS = 2, QUIT = 3}
local MainText = {'Play', 'Options', 'Quit'}
local MainFunctions = nil

local mainMenuSelection = nil

function menustate.init(gamestate)
  MainFunctions = {play, nil, love.event.quit}
end

function menustate.enter()
  mainMenuSelection = MainMenu.PLAY
end

function menustate.update(dt)
  if input.wasKeyPressed('up') then
    if mainMenuSelection ~= 1 then
      mainMenuSelection = mainMenuSelection - 1
    else
      mainMenuSelection = #MainText
    end
  elseif input.wasKeyPressed('down') then
    mainMenuSelection = (mainMenuSelection % #MainText) + 1
  end

  if input.wasKeyPressed('return') or input.wasKeyPressed(' ') then
    if MainFunctions[mainMenuSelection] then
      MainFunctions[mainMenuSelection]()
    end
  end
end

function menustate.draw()
  -- Set background color
  love.graphics.setBackgroundColor(0, 0, 0)

  -- Draw title
  love.graphics.setColor(255, 0, 0)
  love.graphics.printf('BREAKOUT', 0, 100, 800, 'center')
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf('The game, the clone, the experience',
                       0, 200, 800, 'center')

  -- Draw menu
  for i, text in ipairs(MainText) do
    if i == mainMenuSelection then
      love.graphics.setColor(255, 0, 0)
    else
      love.graphics.setColor(255, 255, 255)
    end
    love.graphics.printf(text, 0, 300 + (i - 1)*50, 800, 'center')
  end
end

function play()
  gamestate.switch(GameStates.PLAY_GAME)
end
