input = {}

local heldKeys = {}
local pressedKeys = {}
local releasedKeys = {}

function input.keypressed(key, isrepeat)
  print(key .. ' pressed')
  heldKeys[key] = true
  pressedKeys[key] = true
end

function input.keyreleased(key)
  print(key .. ' released')
  heldKeys[key] = nil
  releasedKeys[key] = true
end

function input.newFrame()
  for key, _ in pairs(pressedKeys) do
    pressedKeys[key] = nil
  end
  for key, _ in pairs(releasedKeys) do
    releasedKeys[key] = nil
  end
end

function input.isKeyHeld(key)
  return heldKeys[key]
end

function input.wasKeyPressed(key)
  return pressedKeys[key]
end

function input.wasKeyReleased(key)
  return releasedKeys[key]
end
