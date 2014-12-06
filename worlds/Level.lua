Level = class("Level", PhysicalWorld)
Level.static.list = { "1" }

function Level:initialize(index)
  PhysicalWorld.initialize(self)
  local xmlFile = love.filesystem.read("assets/levels/" .. Level.list[index] .. ".oel")
  self.xml = slaxml:dom(xmlFile).root
  self.width = getText(self.xml, "width")
  self.height = getText(self.xml, "height")
    
  self.walls = Walls:new(self.xml, self.width, self.height)
  self.floor = Floor:new(self.xml, self.width, self.height)
  self:add(self.walls, self.floor)
  self:loadObjects()  
  
  self:setupLayers{
    [1] = { 1, pre = postfx.exclude, post = postfx.include }, -- walls
    [3] = 1, -- player
    [4] = 1, -- enemies
    [5] = 1, -- projectiles
    [10] = 1 -- floor
  }
end

function Level:loadObjects()
  local o = findChild(self.xml, "objects")
  self.player = Player:fromXML(findChild(o, "player"))
  self:add(self.player)
  
  for _, v in ipairs(findChildren(o, "mauler")) do
    self:add(Mauler:fromXML(v))
  end
  
  for _, v in ipairs(findChildren(o, "circleLight")) do
    local light = lighting:addLight(
      tonumber(v.attr.x),
      tonumber(v.attr.y),
      tonumber(v.attr.radius),
      tonumber(v.attr.innerRadius),
      tonumber(v.attr.intensity)  
    )
    
    light.alpha = tonumber(v.attr.alpha)
  end
end
