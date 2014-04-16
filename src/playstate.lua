require 'math'

require 'src/input'

playstate = {}

local BOUNDARY = 50
local LEFT = nil
local RIGHT = nil
local TOP = nil
local BOTTOM = nil

local level = nil
local score = nil
local life = nil

function left(rect, value)
  if not value then
    return rect.x - rect.width/2
  end
  rect.x = value + rect.width/2
end

function right(rect, value)
  if not value then
    return rect.x + rect.width/2
  end
  rect.x = value - rect.width/2
end

function top(rect, value)
  if not value then
    return rect.y - rect.height/2
  end
  rect.y = value + rect.height/2
end

function bottom(rect, value)
  if not value then
    return rect.y + rect.height/2
  end
  rect.y = value - rect.height/2
end

function overlaps(rect, other)
  return (rect:right() > other:left() and
          rect:left() < other:right() and
          rect:top() < other:bottom() and
          rect:bottom() > other:top())
end

local paddle = {
  width = 100,
  height = 20,
  x = nil,
  y = nil,
  velocity = 200,
}

local ball = {
  width = 20,
  height = 20,
  x = nil,
  y = nil,
  dx = nil,
  dy = nil,
  velocity = 200,
  docked = false,
}

local bricks = {}

function paddle.move(dx)
  paddle.x = paddle.x + dx

  -- Check bounds and adjust position
  if paddle:left() < LEFT then
    paddle.x = LEFT + paddle.width/2
  elseif paddle:right() > RIGHT then
    paddle.x = RIGHT - paddle.width/2
  end
end

function ball.shoot()
  ball.docked = false

  -- Generate random direction to shoot
  -- 90 degree range around the vertical
  local angle = love.math.random() * math.pi/2 + math.pi/4
  ball.dx = ball.velocity * math.cos(angle)
  ball.dy = -ball.velocity * math.sin(angle)
end

function ball.reset()
  ball.docked = true
  ball.followPaddle()
end

function ball.move(dt)
  if ball.docked then
    ball.followPaddle()
  else
    -- Move in current direction
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    -- Check for collisions with walls
    if ball:left() < LEFT then
      local overx = LEFT - ball:left()
      ball:left(LEFT + overx)
      ball.dx = -ball.dx
    elseif ball:right() > RIGHT then
      local overx = ball:right() - RIGHT
      ball:right(RIGHT - overx)
      ball.dx = -ball.dx
    end
    if ball:top() < TOP then
      local overy = TOP - ball:top()
      ball:top(TOP + overy)
      ball.dy = -ball.dy
    elseif ball:bottom() > BOTTOM then
      -- Lose life, reset ball
      life = life - 1
      if life > 0 then
        ball.reset()
      else
        gamestate.push(GameStates.LOSE_GAME)
      end
    end

    -- Check for collisions with paddle
    if ball:overlaps(paddle) then
      local overy = ball:bottom() - paddle:top()
      ball:bottom(paddle:top() - overy)
      ball.dy = -ball.dy
    end
    -- TODO: check for collisions with bricks
  end
end

function ball.followPaddle()
  ball.dx = 0
  ball.dy = 0
  ball.x = paddle.x
  ball.y = paddle.y - paddle.height/2 - 5 - ball.height/2
end

function playstate.init(gamestate)
  BOUNDARY = 50
  LEFT = BOUNDARY
  RIGHT = SCREEN_WIDTH - BOUNDARY
  TOP = BOUNDARY
  BOTTOM = SCREEN_HEIGHT - BOUNDARY

  for _, obj in ipairs({paddle, ball}) do
    obj.left = left
    obj.right = right
    obj.top = top
    obj.bottom = bottom
    obj.overlaps = overlaps
  end
end

function playstate.enter()
  level = 1
  score = 0
  life = 3

  -- Create paddle
  paddle.x = SCREEN_WIDTH/2
  paddle.y = BOTTOM - 5 - paddle.height/2

  -- Create ball
  ball.reset()

  -- TODO: create bricks
end

function playstate.update(dt)
  local dir = 0
  if input.isKeyHeld('left') then
    dir = dir - 1
  end
  if input.isKeyHeld('right') then
    dir = dir + 1
  end
  paddle.move(dir * paddle.velocity * dt)

  if ball.docked and input.wasKeyPressed(' ') then
    ball.shoot()
  end
  ball.move(dt)

  if input.wasKeyPressed('escape') then
    gamestate.push(GameStates.PAUSE_GAME)
  end
end

function playstate.draw()
  -- Draw play space
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', LEFT, TOP,
                          RIGHT - LEFT, BOTTOM - TOP)

  -- TODO: draw bricks

  -- Draw paddle
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', paddle:left(), paddle:top(),
                          paddle.width, paddle.height)

  -- Draw ball
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', ball:left(), ball:top(),
                          ball.width, ball.height)

  -- Draw UI
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf('Level ' .. level, 10, 10, 790, 'left')
  love.graphics.printf('Lives: ' .. life .. '\nScore: ' .. score,
                       0, 10, 790, 'right')
end
