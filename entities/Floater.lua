Floater = class("Floater", Enemy)
Floater.static.width = 20
Floater.static.height = 17

function Floater.static:fromXML(e)
  local f = Floater:new(tonumber(e.attr.x), tonumber(e.attr.y))
  f:patrolFromXML(e)
  return f
end

function Floater:initialize(x, y)
  Enemy.initialize(self, x, y, Floater.width, Floater.height)
  self.speed = 30
  self.alertSpeed = 150
  self.engagement = 70
  self.fireTime = 1
  self.fireTimer = 0
  self.visionSpread = math.tau * 0.4
  self.health = 50
  
  self.map = Spritemap:new(assets.images.floater, 25, 23)
  self.map:add("move", { 1, 2, 3, 2, 1, 4, 5, 4 }, 6, true)
  self.map:add("moveAlert", { 1, 2, 3, 2, 1, 4, 5, 4 }, 15, true)
  self.map:add("idle", { 1, 2, 1, 4 }, 2, true)
  self.map:add("death", { 6, 7, 8, 9, 10 }, 18, false)
  self.map:play("idle")
  
  self.ps = love.graphics.newParticleSystem(assets.images.vaporShot, 100)
  self.ps:setSpread(math.tau)
  self.ps:setParticleLifetime(1.5, 3)
  self.ps:setColors(84, 148, 93, 255, 88, 116, 69, 0)
  self.ps:setSizes(2, 1.5)
  self.ps:setSpeed(3, 25)
  
  self.idleSound = assets.sfx.floaterIdle:loop()
  self.alertSound = assets.sfx.floaterAlert:loop()
  self.alertSound:pause()
end

function Floater:added()
  Enemy.added(self)
  self:setLinearDamping(1)
end

function Floater:update(dt)
  self.map:update(dt)
  
  if self.dead then
    self.ps:update(dt)
    if self.ps:getCount() == 0 then self.world = nil end
    return
  end
  
  Enemy.update(self, dt)
  updateSound(self.idleSound, self.x, self.y)
  updateSound(self.alertSound, self.x, self.y)
  
  if self.movingTo or self.alert == 3 then
    local anim = self.alert > 0 and "moveAlert" or "move"
    if self.map.current ~= anim then self.map:play(anim) end
    
    if not self.alertSound:isPlaying() then
      self.alertSound:resume()
      self.idleSound:pause()
    end
  elseif self.map.current == "idle" then
    self.map:play("idle")
    
    if not self.idleSound:isPlaying() then
      self.idleSound:resume()
      self.alertSound:pause()
    end
  end
end

function Floater:draw()
  if self.dead then love.graphics.draw(self.ps, self.x, self.y) end
  if self.map.current then self.map:draw(self.x, self.y, self.angle, 1, 1, self.map.width / 2, self.map.height / 2) end
end

function Floater:handleAlert(dt)
  if not self.movement then return end
  local p = self.world.player
  local angle = math.angle(self.x, self.y, p.x, p.y)
  local dist = math.distance(self.x, self.y, p.x, p.y)
  self.angle = angle
  
  if dist > self.engagement then
    self:applyForce(self.alertSpeed * math.cos(angle), self.alertSpeed * math.sin(angle))
  end
  
  if self.fireTimer <= 0 then
    self.world:add(VaporShot:new(self.x, self.y, self.angle))
    self.fireTimer = self.fireTime
    self:playRandom{"floaterShoot1", "floaterShoot2"}
  else
    self.fireTimer = self.fireTimer - dt
  end
end

function Floater:die()
  self.dead = true
  self.map:play("death")
  self.ps:emit(math.random(30, 40))
  self.idleSound:stop()
  self.alertSound:stop()
  self:playRandom{"floaterDeath1", "floaterDeath2"}
end
