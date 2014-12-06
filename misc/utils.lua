function getMouse()
  return love.mouse.getX() / postfx.scale, love.mouse.getY() / postfx.scale
end

function Entity:drawImage(image, x, y, ox, oy)
  image = image or self.image
  if self.color then love.graphics.setColor(self.color) end
  
  love.graphics.draw(
    image,
    x or self.x,
    y or self.y,
    self.angle,
    self.scaleX or self.scale or 1,
    self.scaleY or self.scale or 1,
    ox or image:getWidth() / 2,
    oy or image:getHeight() / 2
  )
end
