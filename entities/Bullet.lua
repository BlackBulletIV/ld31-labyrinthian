Bullet = class("Bullet", PhysicalEntity)

function Bullet:initialize(x, y, angle)
  PhysicalEntity.initialize(self, x, y, 0, 0, "ghost")
  self.angle = angle
  self.speed = 100
  self.image = assets.images.bullet
  print(self.angle)
end

function Bullet:update(dt)
  local moveX = self.speed * math.cos(self.angle) * dt
  local moveY = self.speed * math.sin(self.angle) * dt
  self:moveBy(moveX, moveY, "all")
end

function Bullet:draw()
  self:drawImage()
end

function Bullet:moveCollide(entity)
  if instanceOf(Bullet, entity) or instanceOf(Player, entity) then return false end
  self.world = nil
  return true
  -- damage entity
end

Bullet.moveCollideX = moveCollide
Bullet.moveCollideY = moveCollide
