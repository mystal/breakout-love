local Gamestate = require 'lib/hump.gamestate'

local input = require 'src/input'

losestate = {}

local MENU_WIDTH = 300
local MENU_HEIGHT = 400
local MENU_X = nil
local MENU_Y = nil

local Menu = {RETRY = 1, GIVE_UP = 2}
local MenuText = {'Retry', 'Give Up'}
local MenuFunctions = nil

local menuSelection = nil

function losestate.init()
  MENU_X = SCREEN_WIDTH/2
  MENU_Y = SCREEN_HEIGHT/2

  MenuFunctions = {retry, quit}
end

function losestate.enter(from)
  menuSelection = Menu.RETRY
end

function losestate.update(dt)
  if input.wasKeyPressed('up') then
    if menuSelection ~= 1 then
      menuSelection = menuSelection - 1
    else
      menuSelection = #MenuText
    end
  elseif input.wasKeyPressed('down') then
    menuSelection = (menuSelection % #MenuText) + 1
  end

  if input.wasKeyPressed('return') or input.wasKeyPressed(' ') then
    if MenuFunctions[menuSelection] then
      MenuFunctions[menuSelection]()
    end
  end
end

function losestate.draw()
  gamestate.peek(1).draw()

  love.graphics.setColor(180, 180, 180, 230)
  love.graphics.rectangle('fill', MENU_X - MENU_WIDTH/2, MENU_Y - MENU_HEIGHT/2,
                          MENU_WIDTH, MENU_HEIGHT)
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf('You Lose',
                       250, MENU_Y - MENU_HEIGHT/2 + 10, MENU_WIDTH, 'center')

  for i, text in ipairs(MenuText) do
    if i == menuSelection then
      love.graphics.setColor(255, 0, 0)
    else
      love.graphics.setColor(0, 0, 0)
    end
    love.graphics.printf(text, 250, 300 + (i - 1)*50, MENU_WIDTH, 'center')
  end
end

function retry()
  gamestate.pop()
  gamestate.switch(GameStates.PLAY_GAME)
end

function quit()
  gamestate.pop()
  gamestate.switch(GameStates.MENU)
end
