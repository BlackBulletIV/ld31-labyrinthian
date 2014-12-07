Pod = class("Pod", PhysicalEntity)
Pod.static.width = 12
Pod.static.height = 12

function Pod.static:fromXML(e)
  return Pod:new(tonumber(e.attr.x), tonumber(e.attr.y), tonumber(e.attr.payload))
end

function Pod:initialize(x, y, payload)
  PhysicalEntity.initialize(self, x, y, "static")
  self.layer = 4
  self.width = Pod.width
  self.height = Pod.height
  self.payload = payload or 5
  self.range = 70
  self.angle = math.tau * math.random()
  self.map = Spritemap:new(assets.images.pod, 20, 20)
  self.map:add("burst", { 1, 2, 3, 4 }, 10, false)
  self.map.frame = 1
end

function Pod:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(3)
  self.fixture:setMask(1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16) -- all except bullets
  self.fixture:setSensor(true)
end

function Pod:update(dt)
  self.map:update(dt)
  
  if self.bursted then
    self.map.frame = 4
  elseif math.distance(self.x, self.y, self.world.player.x, self.world.player.y) <= self.range then
    self:burst()
  end
end

function Pod:draw()
  self.map:draw(self.x, self.y, self.angle, 1, 1, self.map.width / 2, self.map.height / 2)
end

function Pod:burst()
  if self.bursted then return end
  
  for i = 1, self.payload do
    self.world:add(Spider:new(self.x, self.y, math.tau * math.random()))
  end
  
  self:playRandom{"podBurst1", "podBurst2"}
  self.map:play("burst")
  self.bursted = true
end

function Pod:collided(other, fixture, otherFixture, contact)
  if self.bursted then return end
  if instanceOf(Bullet, other) then self:burst() end
end
