Bullet = class("Bullet", PhysicalEntity)
Bullet.static.width = 10
Bullet.static.height = 1

function Bullet:initialize(x, y, angle)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.width = Bullet.width
  self.height = Bullet.height
  self.angle = angle
  self.speed = 1000
  self.velx = math.cos(angle) * self.speed
  self.vely = math.sin(angle) * self.speed
  self.image = assets.images.bullet
  self.damage = 10
  self.layer = 5
end

function Bullet:added()
  self:setupBody()
  self:setBullet(true)
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(5)
  self.fixture:setMask(2, 5, 6)
  self.fixture:setSensor(true)
end

function Bullet:draw()
  self:drawImage()
end

function Bullet:collided(other, fixture, otherFixture, contact)
  if self.dead then return end
  self:die()
  if instanceOf(Enemy, other) then other:bulletHit(self) end
end

function Bullet:die()
  self.dead = true
  self.world = nil
end
