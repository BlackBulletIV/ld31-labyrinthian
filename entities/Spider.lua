Spider = class("Spider", Enemy)
Spider.static.width = 6
Spider.static.height = 5

function Spider:initialize(x, y, direction)
  Enemy.initialize(self, x, y, Spider.width, Spider.height)
  self.speed = 1000
  self.health = 1
  self.alertSpeed = 2200
  self.searchIncrement = 5
  self.searchPauseMin = 0.5
  self.searchPauseMax = 1.5
  self.angle = direction
  self.directionTime = 1.5
  self.directionTimer = self.directionTime
  self.initialMove = true
  self.visionSpread = math.tau
  
  self.damageTimer = 0
  self.damageTime = 0.5
  self.damageRange = 8
  self.damage = 1
  
  self.map = Spritemap:new(assets.images.spider, 6, 5)
  self.map:add("walk", { 1, 4, 2, 1, 4, 3 }, 13)
  self.map:add("run", { 1, 4, 2, 1, 4, 3 }, 19)
  self.map.frame = 1
  
  self.ps = love.graphics.newParticleSystem(assets.images.particle, 15)
  self.ps:setColors(68, 38, 30)
  self.ps:setSpeed(20, 40)
  self.ps:setParticleLifetime(0.2, 0.5)
  self.ps:setSpread(math.tau)
end

function Spider:added()
  Enemy.added(self)
  self:setLinearDamping(14)
  
  local dist = math.random(5, 25)
  self:animate(math.random(4, 10) / 10, { x = self.x + math.cos(self.angle) * dist, y = self.y + math.sin(self.angle) * dist }, nil, function() self.initialMove = false end)
end

function Spider:update(dt)
  if self.dead then
    self.ps:update(dt)
    if self.ps:getCount() == 0 then self.world = nil end
    return
  end
  
  self.map:update(dt)
  if self.initialMove or self.movingTo or self.alert == 0 or self.alert == 3 then
    local anim = self.alert > 0 and "run" or "walk"
    if self.map.current ~= anim then self.map:play(anim, true) end
  end
  
  if self.initialMove then return end
  Enemy.update(self, dt)
  
  
  if self.damageTimer <= 0 then
    local player = self.world.player
  
    if math.distance(self.x, self.y, player.x, player.y) <= self.damageRange then
      player:damage(self.damage)
      self.damageTimer = self.damageTime
    end
  else
    self.damageTimer = self.damageTimer - dt
  end
end

function Spider:draw()
  if self.dead then
    love.graphics.draw(self.ps, self.x, self.y)
    return
  end
    
  Enemy.draw(self)
  self.map:draw(self.x, self.y, self.angle, 1, 1, self.map.width / 2, self.map.height / 2)
end

function Spider:handleUnaware(dt)
  if self.directionTimer <= 0 then
    self.angle = math.random() * math.tau
  else
    self.directionTimer = self.directionTimer - dt
  end
  
  self:applyForce(self.speed * math.cos(self.angle) * dt, self.speed * math.sin(self.angle) * dt)
end

function Spider:die()
  if self.dead then return end
  self.dead = true
  self.ps:setLinearAcceleration(self:getLinearVelocity())
  self.ps:emit(math.random(10, 15))
  self:destroy()
  self:playRandom{"spiderDeath1", "spiderDeath2"}
end
