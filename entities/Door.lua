Door = class("Door", PhysicalEntity)

function Door.static:fromXML(e)
  local axis = e.attr.axis

  local d = Door:new(
    tonumber(e.attr.x),
    tonumber(e.attr.y),
    tonumber(e.attr.axis == "x" and e.attr.width or e.attr.height),
    axis,
    tonumber(e.attr.direction)
  )
  
  d.moveTime = tonumber(e.attr.moveTime)
  d.delay = tonumber(e.attr.delay)
  return d
end

function Door:initialize(x, y, length, axis, dir)
  PhysicalEntity.initialize(self, x, y, "static")
  self.layer = 2
  self.length = math.round(length / TILE_SIZE)
  self.axis = axis or "x"
  self.dir = dir or 1
  self.opened = false
  
  self.moveTime = 0.3
  self.delay = 2
  self.auto = true
  
  self.width = self.length * TILE_SIZE
  self.height = TILE_SIZE
  if axis == "y" then self.width, self.height = self.height, self.width end
  self.map = Tilemap:new(assets.images.door, TILE_SIZE, TILE_SIZE, self.width, self.height)
  
  if self.axis == "x" then
    if self.dir == -1 then
      self.map:set(0, 0, 1)
    elseif self.dir == 1 then
      self.map:set(length - 1, 0, 3)
    end
    
    if length > 2 then self.map:setRect(1, 0, length - 2, 0, 2) end
  elseif self.axis == "y" then
    if self.dir == -1 then
      self.map:set(0, 0, 4)
    elseif self.dir == 1 then
      self.map:set(0, length - 1, 6)
    end
    
    if length > 2 then self.map:setRect(0, 1, 0, length - 2, 5) end
  end
  
  self.closedPos = self[self.axis]
  self.openedPos = self[self.axis] - self.length * self.dir
  print(x, y, length, axis, dir)
end

function Door:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  
  local shape
  if self.axis == "x" then
    shape = love.physics.newRectangleShape(self.width / 2 * self.dir, 0, 5, self.height)
  else
    shape = love.physics.newRectangleShape(0, self.height / 2 * self.dir, self.width, 5)
  end
  
  self.detector = self:addShape(shape)
  self.detector:setSensor(true)
  if self.auto then self:open(true) end
end

function Door:draw()
  self.map:draw(self.x - self.width / 2, self.y - self.height / 2)
  love.graphics.rectangle("line", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end

function Door:open(continue)
  self.moving = true

  self:animate(self.moveTime, { [self.axis] = self.openedPos }, nil, function()
    self.moving = false
    self.opened = true
    if continue then delay(self.delay, self.close, self) end
  end)
end

function Door:close(complete)
  self.moving = true
  
  self:animate(self.moveTime, { [self.axis] = self.closedPos }, nil, function()
    self.moving = false
    self.opened = false
    if continue then delay(self.delay, self.open, self) end
  end)
end

function Door:collided(other, fixture, otherFixture, contact)
  if fixture == self.detector and self.moving and not other.dead then
    if other.die then other:die() end
  end
end
