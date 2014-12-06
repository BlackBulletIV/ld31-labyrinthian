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
  self.speed = 150
  self.jumpForce = 3000
  self.health = 2
end

function Player:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self:setMass(20)
  self:setLinearDamping(10)
end

function Player:update(dt)
  PhysicalEntity.update(self, dt)
  local axis = input.axisDown("left", "right")
  self.velx = self.speed * axis
  
  if input.pressed("jump") then
    self:applyLinearImpulse(0, -self.jumpForce)
  end
end

function Player:draw()
  self:drawImage()
end
