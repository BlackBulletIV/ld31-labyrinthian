Mauler = class("Mauler", Enemy)
Mauler.width = 9
Mauler.height = 18

function Mauler.static:fromXML(e)
  local m = Mauler:new(tonumber(e.attr.x), tonumber(e.attr.y))
  m:patrolFromXML(e)
  return m
end

function Mauler:initialize(x, y)
  Enemy.initialize(self, x, y, Mauler.width, Mauler.height)
  self.image = assets.images.mauler
  self.speed = 400
  self.alertSpeed = 900
  self.health = 80
end
  
