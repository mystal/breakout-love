require 'src/rect'

local class = require 'lib/middleclass'

Paddle = class('Paddle', Rect)

function Paddle:initialize(x, y, w, h, velocity)
  Rect.initialize(self, x, y, w, h)
  --self.dx = 0
  --self.dy = 0
  self.velocity = velocity
end
