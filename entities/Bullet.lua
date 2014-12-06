Bullet = class("Bullet", Entity)

function Bullet:initialize(x, y, angle)
  Entity.initialize(self, x, y)
  self.angle = 0
end
