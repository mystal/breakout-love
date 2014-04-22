require 'math'

local class = require 'lib/middleclass'

Rect = class('Rect')

function Rect:initialize(x, y, w, h)
  self.x = x
  self.y = y
  self.width = w
  self.height = h
end

function Rect:left(value)
  if not value then
    return self.x - self.width/2
  end
  self.x = value + self.width/2
end

function Rect:right(value)
  if not value then
    return self.x + self.width/2
  end
  self.x = value - self.width/2
end

function Rect:top(value)
  if not value then
    return self.y - self.height/2
  end
  self.y = value + self.height/2
end

function Rect:bottom(value)
  if not value then
    return self.y + self.height/2
  end
  self.y = value - self.height/2
end

function Rect:overlaps(other)
  return (self:right() > other:left() and
          self:left() < other:right() and
          self:top() < other:bottom() and
          self:bottom() > other:top())
end

function Rect:intersection(other)
  local left = math.max(self:left(), other:left())
  local right = math.min(self:right(), other:right())
  local top = math.max(self:top(), other:top())
  local bottom = math.min(self:bottom(), other:bottom())
  return math.max(right - left, 0), math.max(bottom - top, 0)
end
