Player = class("Player", PhysicalEntity)
Player.static.width = 8
Player.static.height = 12

Player.static.weapons = {
  pistol = {
    rate = 6 -- per second
  }
}

function Player.static:fromXML(e)
  return Player:new(
    tonumber(e.attr.x) + Player.width / 2,
    tonumber(e.attr.y) + Player.height / 2
  )
end

function Player:initialize(x, y)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 3
  self.width = Player.width
  self.height = Player.height
  self.image = assets.images.player
  self.speed = 1600
  self.health = 10
  self.weapon = "pistol"
  self.movement = true
  self.weaponTimer = 0
  self.torch = lighting:addBeam(x, y, 0, 280, math.tau / 16, 30, 1)
  self.torchGlow = lighting:addBeam(x, y, 0, 50, math.tau / 6, 0, 0.9)
  self.torchOn = true
  self:toggleTorch(false)
  
  self.flash = lighting:addLight(x, y, 200, 100, 1)
  self.flash.alpha = 0
  self.flashTime = 0.06
  self.flashTimer = 0
  
  self.walkTime = 1 / 3
  self.walkTimer = 0
  
  self.deathMap = Spritemap:new(assets.images.playerDeath, 26, 18)
  self.deathMap:add("death", { 1, 2, 3, 4, 5 }, 12, false)
end

function Player:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(2)
  self:setMass(2)
  self:setLinearDamping(12)
end

function Player:update(dt)
  if self.dead then
    self.deathMap:update(dt)
    return
  end
  
  PhysicalEntity.update(self, dt)
  self:setAngularVelocity(0)
  
  if self.movement then
    self.angle = math.angle(self.x, self.y, getMouse())
    local dir = self:getDirection()
    
    if dir then
      self:applyForce(self.speed * math.cos(dir), self.speed * math.sin(dir))
      
      if self.walkTimer <= 0 then
        playRandom{"step1", "step2", "step3", "step4"}
        self.walkTimer = self.walkTime
      end
    end
    
    if input.pressed("fire") then self:fireWeapon() end
  end
  
  if input.pressed("torch") then self:toggleTorch() end
  
  if self.torchOn then
    self.torch.x = self.x + 8 * math.cos(self.angle) -- offset to torch on image
    self.torch.y = self.y + 8 * math.sin(self.angle)
    self.torch.angle = self.angle
    self.torch.alpha = math.clamp(self.torch.alpha + math.random(0, 320) * dt * (math.random(0, 1) == 1 and 1 or -1), 200, 255)
    
    self.torchGlow.x = self.x - 4 * math.cos(self.angle)
    self.torchGlow.y = self.y - 4 * math.sin(self.angle)
    self.torchGlow.angle = self.angle
    self.torchGlow.alpha = self.torch.alpha
  end
    
  if self.weaponTimer > 0 then self.weaponTimer = self.weaponTimer - dt end
  
  if self.flashTimer > 0 then
    self.flashTimer = self.flashTimer - dt
    if self.flashTimer <= 0 then self.flash.alpha = 0 end
  end
  
  if self.walkTimer > 0 then self.walkTimer = self.walkTimer - dt end
end

function Player:draw()
  if self.dead then
    self.deathMap:draw(self.x, self.y, self.angle, 1, 1, 8, 10)
    return
  end
  
  self:drawImage(self.image, self.x, self.y, self.width / 2, self.height / 2)
  
  if self.flashTimer > 0 then
    love.graphics.draw(
      assets.images.muzzleFlash,
      self.x + 13 * math.cos(self.angle) + 3 * math.cos(self.angle + math.tau / 2),
      self.y + 13 * math.sin(self.angle) + 3 * math.sin(self.angle + math.tau / 2),
      self.angle
    )
  end 
end

function Player:hold()
  self.movement = false
  self.velx = 0
  self.vely = 0
  self.fixture:setSensor(true)
end

function Player:release()
  self.movement = true
  self.fixture:setSensor(false)
end

function Player:damage(health)
  if self.dead then return end
  self.health = self.health - health
  if self.health <= 0 then self:die() end
end

function Player:toggleTorch(sound)
  self.torchOn = not self.torchOn
  self.torch.alpha = self.torchOn and 255 or 0
  self.torchGlow.alpha = self.torch.alpha
  if sound ~= false then playSound("torch") end
end

function Player:die()
  if self.dead then return end
  self.dead = true
  self.movement = false
  self.flash.alpha = 0
  self.deathMap:play("death")
  
  tween(self.torch, 0.35, {
    x = self.x + 20 * math.cos(self.angle) + 4 * math.cos(self.angle - math.tau / 4),
    y = self.y + 20 * math.sin(self.angle) + 4 * math.sin(self.angle - math.tau / 4),
    angle = self.angle - math.tau / 2
  }, ease.quadOut)
  
  delay(0.7, function() fade.out(function()
    ammo.world = Level:new(ammo.world.index, true)
  end) end)
end

function Player:fireWeapon()
  if self.weaponTimer <= 0 then
    local x = self.x + 8 * math.cos(self.angle)-- + 2 * math.cos(self.angle + math.tau / 4) -- offsets to gun on image
    local y = self.y + 8 * math.sin(self.angle)-- + 2 * math.sin(self.angle + math.tau / 4)
    self.world:add(Bullet:new(x, y, math.angle(self.x, self.y, getMouse())))
    self.weaponTimer = 1 / Player.weapons[self.weapon].rate
    
    self.flashTimer = self.flashTime
    self.flash.alpha = math.random(180, 255)
    self.flash.x = self.x
    self.flash.y = self.y
    for e in Enemy.all:iterate() do e:playerFire() end
    
    playRandom{"shoot1", "shoot2", "shoot3"}
  end
end

function Player:getDirection()
  local xAxis = input.axisDown("left", "right")
  local yAxis = input.axisDown("up", "down")
  local xAngle = xAxis == 1 and 0 or (xAxis == -1 and math.tau / 2 or nil)
  local yAngle = yAxis == 1 and math.tau / 4 or (yAxis == -1 and math.tau * 0.75 or nil)
  
  if xAngle and yAngle then
    -- x = 1, y = -1 is a special case the doesn't fit; not sure what I can do about it other than this:
    if xAxis == 1 and yAxis == -1 then return yAngle + math.tau / 8 end
    return (xAngle + yAngle) / 2
  else
    return xAngle or yAngle
  end
end
