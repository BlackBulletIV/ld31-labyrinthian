Player = class("Player", PhysicalEntity)
Player.static.width = 9
Player.static.height = 14

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
  self.accel = 900
  self.jumpSpeed = 150
  self.health = 2
end

function Player:update(dt)
  local axis = input.axisDown("left", "right")
  self.velx = self.velx + self.accel * axis * dt
  
  if not self.inAir and input.pressed("jump") then
    self.vely = self.jumpSpeed
  end
  
  PhysicalEntity.update(self, dt)
end

function Player:draw()
  self:drawImage()
  love.graphics.setColor(0, 255, 0)
  love.graphics.rectangle("line", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end
