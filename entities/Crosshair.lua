Crosshair = class("Crosshair", Entity)

function Crosshair:initialize()
  Entity.initialize(self)
  self.image = assets.images.crosshair
  self.layer = 1
  self.color = { 200, 20, 20 }
end

function Crosshair:update(dt)
  self.x, self.y = getMouse()
end

function Crosshair:draw()
  self:drawImage()
end
