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
  self.alertSpeed = 1800
  self.health = 80
  self.lungeRange = 50
  self.lungeSpeed = 150
  self.map = Spritemap:new(assets.images.mauler, 19, 18)
  self.map:add("walk", { 1, 2, 3, 2, 1, 4, 5, 4 }, 12)
  self.map:add("run", { 1, 2, 3, 2, 1, 4, 5, 4 }, 40)
end

function Mauler:update(dt)
  Enemy.update(self, dt)
  self.map:update(dt)
  
  if self.lunging then
    local player = self.world.player
    
    if self.x > player.x - 1 and self.x < player.x + 1
    and self.y > player.y - 1 and self.y < player.y + 1
    then
      player:die()
      self.lunging = false
      self.movement = true
      self.alert = 0 -- BUG: doesn't return to patrol
    else
      self.map.frame = 1 -- tmp
      self.velx = 0
      self.vely = 0
      
      self.angle = math.angle(self.x, self.y, self.world.player.x, self.world.player.y)
      self.x = self.x + self.lungeSpeed * math.cos(self.angle) * dt
      self.y = self.y + self.lungeSpeed * math.sin(self.angle) * dt
    end
  elseif self.movingTo or self.alert == 3 then
    local anim = self.alert > 0 and "run" or "walk"
    if self.map.current ~= anim then self.map:play(anim) end
  else
    self.map.frame = 1
  end
  
  if self.alert == 3 and math.distance(self.x, self.y, self.world.player.x, self.world.player.y) <= self.lungeRange then
    self:lunge(dt)
  end
end

function Mauler:draw()
  self.map:draw(self.x, self.y, self.angle, 1, 1, self.width / 2, self.height / 2)
end

function Mauler:lunge(dt)
  self.world.player:hold()
  self.lunging = true
  self.movement = false
end
