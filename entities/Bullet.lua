Bullet = class("Bullet", PhysicalEntity)

function Bullet:initialize(x, y, angle)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.angle = angle
  self.speed = 100
  self.image = assets.images.bullet
end

