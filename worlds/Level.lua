Level = class("Level", PhysicalWorld)
Level.static.list = { "1", "2" }

function Level:initialize(index, player)
  PhysicalWorld.initialize(self)
  print(index)
  lighting:clear()
  
  local xmlFile = love.filesystem.read("assets/levels/" .. Level.list[index] .. ".oel")
  self.xml = slaxml:dom(xmlFile).root
  self.width = getText(self.xml, "width")
  self.height = getText(self.xml, "height")
    
  self.walls = Walls:new(self.xml, self.width, self.height)
  self.floor = Floor:new(self.xml, self.width, self.height)
  self.crosshair = Crosshair:new()
  self:add(self.walls, self.floor, self.crosshair)
  
  self.prevPlayer = player
  self:loadObjects()  
  
  self:setupLayers{
    [1] = { 1, pre = postfx.exclude, post = postfx.include }, -- walls
    [2] = 1, -- crosshair
    [3] = 1, -- player
    [4] = 1, -- enemies
    [5] = 1, -- projectiles
    [10] = 1 -- floor
  }
end

function Level:loadObjects()
  local o = findChild(self.xml, "objects")
  
  if self.prevPlayer then
    local pp = self.prevPlayer
    self.player = Player:new(pp.x, pp.y)
    self.player.angle = pp.angle
    self.player.velx = pp.velx
    self.player.vely = pp.vely
    self.player.torchOn = pp.torchOn
    self.player.torch.alpha = pp.torch.alpha
    self.player.torch.angle = pp.torch.angle
  else
    self.player = Player:fromXML(findChild(o, "player"))
  end
  
  self:add(self.player)
  if not o then return end
  
  for _, v in ipairs(findChildren(o, "mauler")) do
    self:add(Mauler:fromXML(v))
  end
  
  for _, v in ipairs(findChildren(o, "transitionZone")) do
    self:add(TransitionZone:fromXML(v))
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
