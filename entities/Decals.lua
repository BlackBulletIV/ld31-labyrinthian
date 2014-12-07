Decals = class("Decals", Entity)

function Decals:initialize(xml, width, height)
  Entity.initialize(self)
  self.width = width
  self.height = height
  self.canvas = love.graphics.newCanvas(width, height)
  if xml then self:loadFromXML(xml) end
end

function Decals:loadFromXML(xml)
  local d = findChild(xml, "decals")
  if not d then return end
  
  love.graphics.setCanvas(self.canvas)
  
  for _, v in ipairs(d.el) do
    local image = assets.images[v.name]
    
    love.graphics.draw(
      image,
      tonumber(v.attr.x) + image:getWidth() / 2,
      tonumber(v.attr.y) + image:getHeight() / 2,
      math.tau * math.random(),
      1, 1,
      image:getWidth() / 2,
      image:getHeight() / 2
    )
  end
end

function Decals:draw()
  love.graphics.draw(self.canvas, 0, 0)
end
