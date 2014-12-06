Player = class("Player", PhysicalEntity)
Player.static.width = 9
Player.static.height = 14

function Player.static:fromXML(e)
  return Player:new(
    tonumber(e.attr.x),
    tonumber(e.attr.y)
  )
end

function Player:initialize(x, y)
  PhysicalEntity.initialize(self, x, y, "dynamic")
  self.layer = 3
  self.width = Player.width
  self.height = Player.height
  self.image = assets.images.player
  self.accel = 1100
  self.jumpSpeed = 220
  self.health = 2
end

function Player:update(dt)
  local axis = input.axisDown("left", "right")
  self.velx = self.velx + self.accel * axis * dt
  
  if input.pressed("jump") and not self.inAir then
    self.vely = -self.jumpSpeed * math.sign(self.gravityMult)
  end
  
  if input.pressed("flip") then self.gravityMult = -self.gravityMult end
  
  PhysicalEntity.update(self, dt)
end

function Player:draw()
  self:drawImage()
  --love.graphics.setColor(0, 255, 0)
  --love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
end
