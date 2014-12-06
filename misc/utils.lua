function Entity:drawImage(image, x, y)
  image = image or self.image
  if self.color then love.graphics.setColor(self.color) end
  local w = image:getWidth() / 2
  local h = image:getHeight() / 2
  
  love.graphics.draw(
    image,
    (x or self.x) + w / 2,
    (y or self.y) + h / 2,
    self.angle,
    self.scaleX or self.scale or 1,
    self.scaleY or self.scale or 1,
    w / 2,
    h / 2
  )
end
