Mauler = class("Mauler", Enemy)
Mauler.width = 9
Mauler.height = 18

function Mauler.static:fromXML(e)
  local m = Mauler:new(tonumber(e.attr.x), tonumber(e.attr.y))
  m:patrolFromXML(e)
  return m
end

function Mauler:initialize(x, y)
  Enemy.initialize(self, x, y, Mauler.width, Mauler.height)
  self.speed = 400
  self.alertSpeed = 1700
  self.health = 70
  self.lungeRange = 50
  self.lungeSpeed = 150
  self.walkTime = 1 / 2
  self.runTime = 1 / 5
  self.walkTimer = 0
  self.map = Spritemap:new(assets.images.mauler, 19, 18)
  self.map:add("walk", { 1, 2, 3, 2, 1, 4, 5, 4 }, 12, true)
  self.map:add("run", { 1, 2, 3, 2, 1, 4, 5, 4 }, 40, true)
  self.map:add("lunge", { 6, 7, 8, 9, 10 }, 35, false)
  self.map:add("death", { 6, 7, 8, 9, 10 }, 20, false)
end

function Mauler:update(dt)
  Enemy.update(self, dt)
  
  if self.lunging then
    local player = self.world.player
        
    if self.x > player.x - 5 and self.x < player.x + 5
    and self.y > player.y - 5 and self.y < player.y + 5
    then
      player:die()
      self.lunging = false
      self.movement = true
      self.alert = 0 -- BUG: doesn't return to patrol
      self.lungeComplete = true
    else
      if self.alert ~= 3 then
        self.lunging = false
        self.movement = true
        player:release()
      else      
        self.velx = 0
        self.vely = 0
        self.angle = math.angle(self.x, self.y, self.world.player.x, self.world.player.y)
        self.x = self.x + self.lungeSpeed * math.cos(self.angle) * dt
        self.y = self.y + self.lungeSpeed * math.sin(self.angle) * dt
      end
    end
  elseif self.movingTo or self.alert == 3 then
    local anim = self.alert > 0 and "run" or "walk"
    if self.map.current ~= anim then self.map:play(anim) end
    
    if self.walkTimer <= 0 then
      self:playRandom{"maulerStep1", "maulerStep2", "maulerStep3", "maulerStep4"}
      self.walkTimer = anim == "run" and self.runTime or self.walkTime
    end
  else
    self.map.frame = self.lungeComplete and 10 or 5
  end
  
  if self.alert == 3 and math.distance(self.x, self.y, self.world.player.x, self.world.player.y) <= self.lungeRange then
    self:lunge(dt)
  end
  
  if self.walkTimer >= 0 then
    self.walkTimer = self.walkTimer - dt
  end
end

function Mauler:draw()
  Enemy.draw(self)
  self.map:draw(self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
end

function Mauler:lunge(dt)
  if self.lunging then return end
  self.world.player:hold()
  self.lunging = true
  self.movement = false
  self.map:play("lunge")
  
  if not self.lungeSound or not self.lungeSound:isPlaying() then
    self.lungeSound = self:playSound("maulerLunge")
  end
end
