TransitionZone = class("TransitionZone", PhysicalEntity)

function TransitionZone.static:fromXML(e)
  local w, h = tonumber(e.attr.width), tonumber(e.attr.height)
  
  return TransitionZone:new(
    tonumber(e.attr.x) + w / 2,
    tonumber(e.attr.y) + h / 2,
    w,
    h,
    tonumber(e.attr.index),
    math.rad(tonumber(e.attr.facing))
  )
end

function TransitionZone:initialize(x, y, width, height, index, facing)
  PhysicalEntity.initialize(self, x, y, "static")
  self.width = width
  self.height = height
  self.index = index
  self.facing = facing
  self.facingRange = math.tau / 4
end

function TransitionZone:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setSensor(true)
  self.fixture:setMask(1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16) -- all except player
end

function TransitionZone:update(dt)
  PhysicalEntity.update(self, dt)
  
  if self.contact then
    local facing = Vector(math.cos(self.facing), math.sin(self.facing)):normalize()
    local player = Vector(math.cos(self.world.player.angle), math.sin(self.world.player.angle)):normalize()
    local angle = math.acos(math.clamp(-(facing * player), -1, 1)) -- the negation of the dot product is a dirty edit - no idea why it needs it
    
    if angle < self.facingRange then
      state.saveLevel()
      state.savePlayer()
      ammo.world = Level:new(self.index)
      self.transitioned = true
    end
  end
end

function TransitionZone:collided(other, fixture, otherFixture, contact)
  if instanceOf(Player, other) then self.contact = true end
end

function TransitionZone:endCollided(other, fixture, otherFixture, contact)
  if instanceOf(Player, other) then self.contact = false end
end
