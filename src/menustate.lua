require 'src/input'

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

  if input.wasKeyPressed('return') then
    if MainFunctions[mainMenuSelection] then
      MainFunctions[mainMenuSelection]()
    end
  end
end

function menustate.draw()
  for i, text in ipairs(MainText) do
    if i == mainMenuSelection then
      love.graphics.setColor(255, 0, 0)
    else
      love.graphics.setColor(255, 255, 255)
    end
    love.graphics.printf(text, 400, 300 + (i - 1)*50, 0, 'center')
  end
end

function play()
  gamestate.switch(GameStates.PLAY_GAME)
end
