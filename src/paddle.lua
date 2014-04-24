local class = require 'lib/middleclass'

local Rect = require 'src/rect'

Paddle = class('Paddle', Rect)

function Paddle:initialize(x, y, w, h, velocity)
  Rect.initialize(self, x, y, w, h)
  --self.dx = 0
  --self.dy = 0
  self.velocity = velocity
end

return Paddle
