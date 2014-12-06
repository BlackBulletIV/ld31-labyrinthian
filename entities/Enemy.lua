Enemy = class("Enemy", PhysicalEntity)

function Enemy:initialize(x, y, width, height)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.width = width
  self.height = height
  self.alert = 0 -- 0: unaware, 1: suspicious, 2: searching, 3: engaging
  self.lastKnownPosition = nil
  self.lastKnownAngle = nil
  self.patrolMin = 2
  self.patrolMax = 5
  self.patrolTimer = 0
  self.layer = 4
  
  self.speed = 500
  self.alertSpeed = 1600
  self.searchTime = 30
  self.visionRange = 100
  self.visionSpread = math.tau / 3
  self.hearingRange = 20
end

function Enemy:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(3)
  self:setMass(2)
  self:setLinearDamping(12)
end

function Enemy:update(dt)
  PhysicalEntity.update(self, dt)
  self:setAngularVelocity(0)
  
  if self.movingTo then
    if self.x > self.movingTo.x - 1 and self.x < self.movingTo.x + 1
    and self.y > self.movingTo.y - 1 and self.y < self.movingTo.y + 1
    then
      self.movingTo = nil
      if self.movingComplete then
        self.movingComplete()
        self.movingComplete = nil
      end
    else
      local speed = self.alert > 0 and self.alertSpeed or self.speed
      self.angle = math.angle(self.x, self.y, self.movingTo.x, self.movingTo.y)
      self:applyForce(speed * math.cos(self.angle), speed * math.sin(self.angle))
    end
  end
  
  if self.alert == 0 then
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
  elseif self.alert == 1 then
    
  elseif self.alert == 2 then
    if self.searchTimer <= 0 then
      self.alert = 0
    else
      self.searchTimer = self.searchTimer - dt
    end
  elseif self.alert == 3 then
    local px, py = self.world.player.x, self.world.player.y
    self.angle = math.angle(self.x, self.y, px, py)
    self:applyForce(self.alertSpeed * math.cos(self.angle), self.alertSpeed * math.sin(self.angle))
  end
  
  self:detect()
end

function Enemy:draw()
  self:drawImage()
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

function Enemy:detect()
  local player = self.world.player
  local detectedVision = self.visionRange > 0
  local detectedHearing = self.hearingRange > 0
  
  if detectedVision then
    local facing = Vector(math.cos(self.angle), math.sin(self.angle)):normalize()
    local diff = (player.pos - self.pos):normalize()
    local angle = math.acos(facing * diff)
    
    if angle <= self.visionSpread / 2 then
      self.world:rayCast(self.x, self.y, player.x, player.y, function(fixture)
        local entity = fixture:getUserData()
        
        if instanceOf(Walls, entity) then
          detectedVision = false
          return 0
        else
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
    self.alert = 2
    self.lastKnownPosition = player.pos / 1 -- clone
    self.lastKnownAngle = player.angle
    self.searchTimer = self.searchTime
  end
end

function Enemy:die()
  self.world = nil
  self.dead = true
end

function Enemy:bulletHit(bullet)
  if self.dead then return end
  self.health = self.health - bullet.damage
  
  if self.health <= 0 then
    self:die()
  elseif self.alert < 3 then
    self.alert = 2
    self.angle = (bullet.angle + math.tau / 2) % math.tau -- this shit doesn't work
  end
end
