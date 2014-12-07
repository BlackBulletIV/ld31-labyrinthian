VaporShot = class("VaporShot", PhysicalEntity)
VaporShot.width = 5
VaporShot.height = 5

function VaporShot:initialize(x, y, angle)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.width = VaporShot.width
  self.height = VaporShot.height
  self.angle = angle
  self.speed = 200
  self.velx = math.cos(angle) * self.speed
  self.vely = math.sin(angle) * self.speed
  self.damage = 20
  self.layer = 5
  
  self.ps = love.graphics.newParticleSystem(assets.images.vaporShot, 100)
  self.ps:setEmitterLifetime(-1)
  self.ps:setEmissionRate(50)
  self.ps:setParticleLifetime(0.8, 1.5)
  self.ps:setSpeed(0, 0)
  self.ps:setSizes(1, 0.9, 0.5)
  self.ps:setSizeVariation(0.2)
  self.ps:setColors(88, 244, 71, 255, 116, 180, 86, 0)
  self.ps:start()
end

function VaporShot:added()
  self:setupBody()
  self:setBullet(true)
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(6)
  self.fixture:setMask(3, 5, 6)
  self.fixture:setSensor(true)
end

function VaporShot:update(dt)
  PhysicalEntity.update(self, dt)
  self.ps:moveTo(self.x, self.y)
  self.ps:update(dt)
end

function VaporShot:draw()
  love.graphics.draw(self.ps)
  --love.graphics.rectangle("line", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function VaporShot:collided(other, fixture, otherFixture, contact)
  if self.dead then return end
  self:die()
  if instanceOf(Player, other) then other:damage(self.damage) end
end

function VaporShot:die()
  self.dead = true
  self.world = nil
end
