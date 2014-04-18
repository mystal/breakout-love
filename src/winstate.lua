winstate = {}

local MENU_WIDTH = 300
local MENU_HEIGHT = 400
local MENU_X = nil
local MENU_Y = nil

local Menu = {PLAY_AGAIN = 1, QUIT = 2}
local MenuText = {'Play Again', 'Quit'}
local MenuFunctions = nil

local menuSelection = nil

function winstate.init()
  MENU_X = SCREEN_WIDTH/2
  MENU_Y = SCREEN_HEIGHT/2

  MenuFunctions = {playagain, quit}
end

function winstate.enter()
  menuSelection = Menu.PLAY_AGAIN
end

function winstate.update(dt)
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

function winstate.draw()
  gamestate.peek(1).draw()

  love.graphics.setColor(180, 180, 180, 230)
  love.graphics.rectangle('fill', MENU_X - MENU_WIDTH/2, MENU_Y - MENU_HEIGHT/2,
                          MENU_WIDTH, MENU_HEIGHT)
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf('You Win!',
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

function playagain()
  gamestate.pop()
  gamestate.switch(GameStates.PLAY_GAME)
end

function quit()
  gamestate.pop()
  gamestate.switch(GameStates.MENU)
end
