require 'src/losestate'
require 'src/menustate'
require 'src/playstate'
require 'src/pausestate'
require 'src/winstate'

gamestate = {}

GameStates = {
  MENU = 1,
  PLAY_GAME = 2,
  PAUSE_GAME = 3,
  WIN_GAME = 4,
  LOSE_GAME = 5,
}

local gameStack = {}
local states = {menustate, playstate, pausestate, winstate, losestate}

function gamestate.init()
  for _, state in ipairs(states) do
    if state.init then
      state.init(gamestate)
    end
  end

  gamestate.push(GameStates.MENU)
end

function gamestate.update(dt)
  states[current()].update(dt)

  input.newFrame()
end

function gamestate.draw()
  states[current()].draw()
end

function gamestate.push(state)
  print(string.format('Pushing state %d', state))
  if states[state].enter then
    states[state].enter()
  end
  table.insert(gameStack, state)
end

function gamestate.pop()
  if gamestate.depth() == 0 then
    print('No state to pop')
    return nil
  end

  local state = table.remove(gameStack)
  print(string.format('Popping state %d', state))
  if states[state].exit then
    states[state].exit()
  end

  return state
end

function gamestate.switch(state)
  print(string.format('Switching to %d', state))
  gamestate.pop()
  gamestate.push(state)
end

function current()
  return gameStack[#gameStack]
end

function gamestate.peek(n)
  return states[gameStack[#gameStack - n]]
end

function gamestate.depth()
  return #gameStack
end
