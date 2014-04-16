pausestate = {}

local MENU_WIDTH = 300
local MENU_HEIGHT = 400
local MENU_X = nil
local MENU_Y = nil

local Menu = {CONTINUE = 1, OPTIONS = 2, QUIT = 3}
local MenuText = {'Continue', 'Options', 'Quit'}
local MenuFunctions = nil

local menuSelection = nil

function pausestate.init()
  MENU_X = SCREEN_WIDTH/2
  MENU_Y = SCREEN_HEIGHT/2

  MenuFunctions = {continue, nil, quit}
end

function pausestate.enter()
  menuSelection = Menu.CONTINUE
end

function pausestate.update(dt)
  if input.wasKeyPressed('up') then
    if menuSelection ~= 1 then
      menuSelection = menuSelection - 1
    else
      menuSelection = #MenuText
    end
  elseif input.wasKeyPressed('down') then
    menuSelection = (menuSelection % #MenuText) + 1
  end

  if input.wasKeyPressed('escape') then
    continue()
  elseif input.wasKeyPressed('return') then
    if MenuFunctions[menuSelection] then
      MenuFunctions[menuSelection]()
    end
  end
end

function pausestate.draw()
  gamestate.peek(1).draw()

  love.graphics.setColor(120, 120, 120, 120)
  love.graphics.rectangle('fill', MENU_X - MENU_WIDTH/2, MENU_Y - MENU_HEIGHT/2,
                          MENU_WIDTH, MENU_HEIGHT)
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf('Paused',
                       MENU_X, MENU_Y - MENU_HEIGHT/2 + 10, 0, 'center')

  for i, text in ipairs(MenuText) do
    if i == menuSelection then
      love.graphics.setColor(255, 0, 0)
    else
      love.graphics.setColor(0, 0, 0)
    end
    love.graphics.printf(text, 400, 300 + (i - 1)*50, 0, 'center')
  end
end

function continue()
  gamestate.pop()
end

function quit()
  gamestate.pop()
  gamestate.switch(GameStates.MENU)
end
