function Entity:drawImage(image, x, y)
  image = image or self.image
  if self.color then love.graphics.setColor(self.color) end
  
  love.graphics.draw(
    image,
    x or self.x,
    y or self.y,
    self.angle,
    self.scaleX or self.scale or 1,
    self.scaleY or self.scale or 1
    --image:getWidth() / 2,
    --image:getHeight() / 2
  )
end
