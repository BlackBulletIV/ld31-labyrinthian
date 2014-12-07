TextZone = class("TextZone", PhysicalEntity)

function TextZone.static:fromXML(e)
  local w, h = tonumber(e.attr.width), tonumber(e.attr.height)
  
  return TextZone:new(
    tonumber(e.attr.x) + w / 2,
    tonumber(e.attr.y) + h / 2,
    w,
    h,
    e.attr.text,
    tonumber(e.attr.time),
    tonumber(e.attr.delay)
  )
end

function TextZone:initialize(x, y, width, height, text, time, delay)
  PhysicalEntity.initialize(self, x, y, "static")
  self.width = width
  self.height = height
  self.text = text
  self.time = time
  self.delay = delay or 0
end

function TextZone:added()
  self:setupBody()
  self.fixture = self:addShape(love.physics.newRectangleShape(self.width, self.height))
  self.fixture:setSensor(true)
  self.fixture:setMask(1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16) -- everything except player
end

function TextZone:collided(other, fixture, otherFixture, contact)
  if instanceOf(Player, other) then
    if self.delay then
      delay(self.delay, text.display, self.time, self.text)
    else
      text.display(self.time, self.text)
    end
    
    self.world = nil
  end
end
