local class = require 'lib/middleclass'

require 'src/rect'

Brick = class('Brick', Rect)

function Brick:initialize(x, y, w, h, color, points, hits)
  Rect.initialize(self, x, y, w, h)
  self.color = color or {0, 0, 0}
  self.points = points or 1
  self.hits = hits or 1
end
