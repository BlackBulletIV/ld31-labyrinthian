CollisionRect = class("CollisionRect", PhysicalEntity)

function CollisionRect:initialize(x, y, width, height)
  PhysicalEntity.initialize(self, x, y, width, height, "static")
  self.id = math.random(1, 10000)
end

function CollisionRect:draw()
  love.graphics.setColor(255, 0, 0)
  love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
end
