local math = require 'math'

local class = require 'lib/middleclass'

local Rect = require 'src/rect'

local Ball = class('Ball', Rect)

function Ball:initialize(x, y, w, h, velocity, paddle)
  Rect.initialize(self, x, y, w, h)
  self.dx = 0
  self.dy = 0
  self.velocity = velocity
  self.docked = false
  self.paddle = paddle
end

function Ball:reset()
  self.docked = true
  self:followPaddle()
end

function Ball:followPaddle()
  self.dx = 0
  self.dy = 0
  self.x = self.paddle.x
  self.y = self.paddle.y - self.paddle.height/2 - 5 - self.height/2
end

function Ball:shoot()
  self.docked = false

  -- Generate random direction to shoot
  -- 90 degree range around the vertical
  local angle = love.math.random() * math.pi/2 + math.pi/4
  self.dx = self.velocity * math.cos(angle)
  self.dy = -self.velocity * math.sin(angle)
end

return Ball
