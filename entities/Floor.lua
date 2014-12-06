Floor = class("Floor", Entity)

function Floor:initialize(xml, width, height)
  Entity.initialize(self)
  self.layer = 1
  self.width = width
  self.height = height
  self.map = Tilemap:new(assets.images.tiles, TILE_SIZE, TILE_SIZE, width, height)
  self.map.usePositions = true
  self.xml = xml
end

function Floor:added()
  if self.xml then self:setupFromXML(self.xml) end
end

function Floor:setupFromXML(xml)
  local elem = findChild(xml, "floor")
  
  for _, v in ipairs(findChildren(elem, "tile")) do
    self.map:set(tonumber(v.attr.x), tonumber(v.attr.y), tonumber(v.attr.id) + 1)
  end
  
  for _, v in ipairs(findChildren(elem, "rect")) do
    self.map:setRect(
      tonumber(v.attr.x),
      tonumber(v.attr.y),
      tonumber(v.attr.w),
      tonumber(v.attr.h),
      tonumber(v.attr.id) + 1
    )
  end
  
  elem = findChild(xml, "collision")
  
  for _, v in ipairs(findChildren(elem, "rect")) do
    local w, h = tonumber(v.attr.w), tonumber(v.attr.h)
    self.world:add(CollisionRect:new(tonumber(v.attr.x), tonumber(v.attr.y), w, h))
  end
end

function Floor:draw()
  self.map:draw(self.x, self.y)
end
