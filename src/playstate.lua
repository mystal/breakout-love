require 'math'

require 'src/input'

playstate = {}

local BOUNDARY = 50
local LEFT = nil
local RIGHT = nil
local TOP = nil
local BOTTOM = nil

local BRICK_COLORS = {
  {255, 0, 0}, -- red
  {255, 127, 0}, -- orange
  {255, 255, 0}, -- yellow
  {0, 255, 0}, -- green
}

local level = nil
local score = nil
local life = nil
local brickCount = nil

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

local bricks = nil

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

function intersection(rect, other)
  local left = math.max(rect:left(), other:left())
  local right = math.min(rect:right(), other:right())
  local top = math.max(rect:top(), other:top())
  local bottom = math.min(rect:bottom(), other:bottom())
  return math.max(right - left, 0), math.max(bottom - top, 0)
end

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
      -- TODO: check if hit top or sides
      -- TODO: bounce if hits side

      -- Affect angle depending on where it hit paddle
      local x = paddle.x - ball.x
      local angle = (x/paddle.width*2) * math.pi/3 + math.pi/2
      print('Paddle bounce angle: ' .. (angle * 180/math.pi))
      ball.dx = ball.velocity * math.cos(angle)
      ball.dy = -ball.velocity * math.sin(angle)
      local overy = ball:bottom() - paddle:top()
      ball:bottom(paddle:top() - overy)
    end

    -- Check for collisions with bricks
    for j, row in ipairs(bricks) do
      for i, brick in ipairs(row) do
        if brick and ball:overlaps(brick) then
          -- Score!
          score = score + brick.points

          -- Bounce ball
          local width, height = ball:intersection(brick)
          print('Width: ' .. width .. ', Height: ' .. height)
          if width > height then
            if ball.dy > 0 then
              -- Hit top
              print('Hit top')
              local overy = ball:bottom() - brick:top()
              ball:bottom(brick:top() - overy)
            else
              -- Hit bottom
              print('Hit bottom')
              local overy = brick:bottom() - ball:top()
              ball:top(brick:bottom() + overy)
            end
            ball.dy = -ball.dy
          else
            if ball.dx > 0 then
              -- Hit left
              print('Hit left')
              local overx = ball:right() - brick:left()
              ball:right(brick:left() - overx)
            else
              -- Hit right
              print('Hit right')
              local overx = brick:right() - ball:left()
              ball:left(brick:right() + overx)
            end
            ball.dx = -ball.dx
          end

          -- Destroy brick
          bricks[j][i] = false
          brickCount = brickCount - 1
          if brickCount == 0 then
            gamestate.push(GameStates.WIN_GAME)
          end
        end
      end
    end
  end
end

function ball.followPaddle()
  ball.dx = 0
  ball.dy = 0
  ball.x = paddle.x
  ball.y = paddle.y - paddle.height/2 - 5 - ball.height/2
end

function newBrick(x, y, color, points, hits)
  return {
    x = x,
    y = y,
    width = 100,
    height = 50,
    color = color or {0, 0, 0},
    points = points or 1,
    hits = hits or 1,

    left = left,
    right = right,
    top = top,
    bottom = bottom,
    overlaps = overlaps,
    intersection = intersection,
  }
end

function playstate.init(gamestate)
  BOUNDARY = 50
  LEFT = BOUNDARY
  RIGHT = SCREEN_WIDTH - BOUNDARY
  TOP = BOUNDARY
  BOTTOM = SCREEN_HEIGHT

  for _, obj in ipairs({paddle, ball}) do
    obj.left = left
    obj.right = right
    obj.top = top
    obj.bottom = bottom
    obj.overlaps = overlaps
    obj.intersection = intersection
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

  -- Create bricks
  bricks = {}
  brickCount = 0
  for j = 0, 3 do
    local y = TOP + 80 + j * 50 + 25
    table.insert(bricks, {})
    for i = 0, 6 do
      local x = LEFT + i * 100 + 50
      local color = BRICK_COLORS[j + 1]
      local points = (3 - j) * 2 + 1
      local brick = newBrick(x, y, color, points)
      table.insert(bricks[#bricks], brick)
      brickCount = brickCount + 1
    end
  end
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
  -- Set border color
  love.graphics.setBackgroundColor(180, 180, 180)

  -- Draw play space
  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle('fill', LEFT, TOP,
                          RIGHT - LEFT, BOTTOM - TOP)

  -- Draw bricks
  for _, row in ipairs(bricks) do
    --love.graphics.setColor()
    for _, brick in ipairs(row) do
      if brick then
        love.graphics.setColor(unpack(brick.color))
        love.graphics.rectangle('fill', brick:left(), brick:top(),
                                brick.width, brick.height)
        love.graphics.setColor(255, 255, 255)
        love.graphics.rectangle('line', brick:left(), brick:top(),
                                brick.width, brick.height)
      end
    end
  end

  -- Draw paddle
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', paddle:left(), paddle:top(),
                          paddle.width, paddle.height)

  -- Draw ball
  love.graphics.setColor(255, 255, 255)
  love.graphics.rectangle('fill', ball:left(), ball:top(),
                          ball.width, ball.height)

  -- Draw UI
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf('Level ' .. level, 10, 10, 790, 'left')
  love.graphics.printf('Lives: ' .. life .. '\nScore: ' .. score,
                       0, 10, 790, 'right')
end
