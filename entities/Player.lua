Player = class("Player", PhysicalEntity)
Player.static.width = 9
Player.static.height = 14

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
  self.speed = 2400
  self.health = 2
  self.weapon = "pistol"
  self.weaponTimer = 0
end

function Player:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setCategory(2)
  self:setMass(2)
  self:setLinearDamping(12)
end

function Player:update(dt)
  PhysicalEntity.update(self, dt)
  self:setAngularVelocity(0)
  self.angle = math.angle(self.x, self.y, getMouse())
  local dir = self:getDirection()
  if dir then self:applyForce(self.speed * math.cos(dir), self.speed * math.sin(dir)) end
    
  if input.pressed("fire") then self:fireWeapon() end
  
  if self.weaponTimer > 0 then self.weaponTimer = self.weaponTimer - dt end
end

function Player:draw()
  self:drawImage()
end

function Player:fireWeapon()
  if self.weaponTimer <= 0 then
    self.world:add(Bullet:new(self.x, self.y, math.angle(self.x, self.y, getMouse())))
    self.weaponTimer = 1 / Player.weapons[self.weapon].rate
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
