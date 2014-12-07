Enemy = class("Enemy", PhysicalEntity)
Enemy.static.all = LinkedList:new("_enemyNext", "_enemyPrev")

function Enemy:initialize(x, y, width, height)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 4
  self.width = width
  self.height = height
  self.movement = true
  self.alert = 0 -- 0: unaware, 1: suspicious, 2: searching, 3: engaging
  self.lastKnownPosition = nil
  self.lastKnownAngle = nil
  self.patrolMin = 2
  self.patrolMax = 5
  self.patrolTimer = 0
  
  self.searchTimer = 0
  self.searchPauseTimer = 0
  self.searchPauseMin = 1
  self.searchPauseMax = 4
  self.searchIncrement = 10
  self.searchPerimeter = 0
  
  self.speed = 500
  self.alertSpeed = 1000
  self.searchTime = 30
  self.visionRange = 250
  self.visionSpread = math.tau / 3
  self.hearingRange = 50
  self.fireHearingRange = 250
end

function Enemy:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(3)
  self.fixture:setMask(3)
  self:setMass(2)
  self:setLinearDamping(12)
  Enemy.all:push(self)
end

function Enemy:removed()
  self:destroy()
  Enemy.all:remove(self)
end

function Enemy:update(dt)
  PhysicalEntity.update(self, dt)
  self:setAngularVelocity(0)
  
  if self.movingTo and self.movement then
    if self.x > self.movingTo.x - 1 and self.x < self.movingTo.x + 1
    and self.y > self.movingTo.y - 1 and self.y < self.movingTo.y + 1
    then
      self.movingTo = nil
      if self.movingComplete then
        self.movingComplete(self)
        self.movingComplete = nil
      end
    else
      local speed = self.alert > 0 and self.alertSpeed or self.speed
      self.angle = math.angle(self.x, self.y, self.movingTo.x, self.movingTo.y)
      self:applyForce(speed * math.cos(self.angle), speed * math.sin(self.angle))
    end
  end
  
  if self.alert == 0 then
    self:handleUnaware(dt)
  elseif self.alert == 1 then
    self:handleSuspicious(dt)
  elseif self.alert == 2 then
    self:handleSearching(dt)
  elseif self.alert == 3 then
    self:handleAlert(dt)
  end
  
  self:detect()
end

function Enemy:draw()
  --self:drawImage()
  do return end
  
  if self.rayTest ~= nil then
    if self.rayTest then
      love.graphics.setColor(0, 255, 0)
    else
      love.graphics.setColor(255, 0, 0)
    end
    
    love.graphics.line(self.x, self.y, self.world.player.x, self.world.player.y)
    love.graphics.print(self.alert, self.x, self.y)
  end
end

function Enemy:moveTo(x, y, complete)
  self.movingTo = Vector(x, y)
  self.movingComplete = complete
end

function Enemy:setupPatrol(...)
  self.patrol = { ... }
  self.patrolIndex = 1
end

function Enemy:patrolFromXML(e)
  local t = {}
  
  for _, v in ipairs(findChildren(e, "node")) do
    t[#t + 1] = tonumber(v.attr.x)
    t[#t + 1] = tonumber(v.attr.y)
  end
  
  self.patrol = t
  self.patrolIndex = 1
end

function Enemy:handleUnaware(dt)
  if self.patrolTimer <= 0 then
    if not self.patrol then
      self:animate(0.8, { angle = math.random() * math.tau })
      self.patrolTimer = math.random(self.patrolMin * 10, self.patrolMax * 10) / 10
    elseif not self.patrolMoving then
      self.patrolIndex = self.patrolIndex + 2 
      if self.patrolIndex > #self.patrol then self.patrolIndex = 1 end
      self.patrolMoving = true

      self:moveTo(self.patrol[self.patrolIndex], self.patrol[self.patrolIndex + 1], function()
        self.patrolMoving = false
        self.patrolTimer = math.random(self.patrolMin * 10, self.patrolMax * 10) / 10
      end)
    end
  else
    self.patrolTimer = self.patrolTimer - dt
  end
end

function Enemy:handleSuspicious(dt)
end

function Enemy:handleSearching(dt)
  if self.searchTimer <= 0 then
    self.alert = 0
  else
    self.searchTimer = self.searchTimer - dt
  end
  
  if not self.movingTo then
    if self.searchPauseTimer <= 0 then
      self.searchPerimeter = self.searchPerimeter + self.searchIncrement
      local collide = true
      local px, py, angle
      
      repeat
        if self.lastKnownAngle then
          angle = self.lastKnownAngle - math.tau / 24 + math.random() * (math.tau / 12)
        else
          angle = math.random() * math.tau
        end
        
        px = self.x + math.cos(angle) * self.searchPerimeter
        py = self.y + math.sin(angle) * self.searchPerimeter
        local newCollide = false
        
        self.world:rayCast(self.x, self.y, px, py, function(fixture)
          local entity = fixture:getUserData()
          
          if instanceOf(Walls, entity) then
            newCollide = true
            return 0
          else
            return 1
          end
        end)
        
        if newCollide then
          self.lastKnownAngle = nil
        else
          collide = false
        end
      until not collide
      
      self:moveTo(px, py, self.resetPauseTimer)
      self.lastKnownAngle = nil
    else
      self.searchPauseTimer = self.searchPauseTimer - dt
    end
  end
end

function Enemy:handleAlert(dt)
  if self.movement then
    local px, py = self.world.player.x, self.world.player.y
    self.angle = math.angle(self.x, self.y, px, py)
    self:applyForce(self.alertSpeed * math.cos(self.angle), self.alertSpeed * math.sin(self.angle))
  end
end

function Enemy:detect()
  local player = self.world.player
  
  if player.dead then
    self.alert = 0
    return
  end
  
  local detectedVision = self.visionRange > 0 and (player.torchOn or player.flashTimer > 0)
  local detectedHearing = self.hearingRange > 0
  
  if detectedVision then
    local facing = Vector(math.cos(self.angle), math.sin(self.angle)):normalize()
    local diff = (player.pos - self.pos):normalize()
    local angle = math.acos(math.clamp(facing * diff, -1, 1))
    
    if angle <= self.visionSpread / 2 then
      local correction = 15
      
      self.world:rayCast(self.x - correction * math.cos(self.angle), self.y - correction * math.sin(self.angle), player.x, player.y, function(fixture)
        local entity = fixture:getUserData()
        
        if instanceOf(Walls, entity) then
          detectedVision = false
          self.rayTest = false
          return 0
        else
          self.rayTest = true
          return 1
        end
      end)
    else
      detectedVision = false
    end
  end
  
  if detectedHearing then
    if math.distance(self.x, self.y, player.x, player.y) > self.hearingRange then
      detectedHearing = false
    elseif (player.velx + player.vely) / 2 < 5 then
      detectedHearing = false
    end
  end
  
  if detectedVision or detectedHearing then
    self.alert = 3
    self.movingTo = nil
  elseif self.alert == 3 then
    self:startSearch()
  end
end

function Enemy:startSearch(takeAngle)
  local p = self.world.player
  self.lastKnownPosition = p.pos / 1 -- clone
  if takeAngle ~= false then self.lastKnownAngle = p.angle end
  
  self.alert = 2
  self.searchTimer = self.searchTime
  self.searchPauseTimer = 0
  self:moveTo(self.lastKnownPosition.x, self.lastKnownPosition.y, self.resetPauseTimer)
end

function Enemy:die()
  self.world = nil
  self.dead = true
end

function Enemy:bulletHit(bullet)
  if self.dead then return end
  self.health = self.health - bullet.damage
  if self.health <= 0 then self:die() end
end

function Enemy:playerFire()
  local p = self.world.player.pos

  if self.alert < 3 and self.hearingRange > 0 and math.distance(self.x, self.y, p.x, p.y) < self.fireHearingRange then
    self:startSearch(false)
  end
end

function Enemy:resetPauseTimer()
  self.searchPauseTimer = math.random(self.searchPauseMin * 10, self.searchPauseMax * 10) / 10
end
