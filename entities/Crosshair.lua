Crosshair = class("Crosshair", Entity)

function Crosshair:initialize()
  Entity.initialize(self)
  self.image = assets.images.crosshair
  self.layer = 2
  self.color = { 220, 0, 0 }
end

function Crosshair:update(dt)
  self.x, self.y = getMouse()
end

function Crosshair:draw()
  self:drawImage()
end
