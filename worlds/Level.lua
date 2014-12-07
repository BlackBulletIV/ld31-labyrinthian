Level = class("Level", PhysicalWorld)

function Level:initialize(index, death)
  PhysicalWorld.initialize(self)
  lighting:clear()
  if death then fade.into() end
  love.audio.pause()
  bgSfx:resume()

  local xmlFile = love.filesystem.read("assets/levels/" .. index .. ".oel")
  self.index = index
  self.xml = slaxml:dom(xmlFile).root
  self.width = getText(self.xml, "width")
  self.height = getText(self.xml, "height")
    
  self.walls = Walls:new(self.xml, self.width, self.height)
  self.floor = Floor:new(self.xml, self.width, self.height)
  self.decals = Decals:new(nil, self.width, self.height)
  self.crosshair = Crosshair:new()
  self:add(self.walls, self.floor, self.crosshair)
  
  local obj = findChild(self.xml, "objects")
  
  if death and state.entrance then
    self.player = Player:new(state.entrance:unpack())
  elseif state.player then
    self.player = state.createPlayer()
  else
    self.player = Player:fromXML(findChild(obj, "player"))
  end
  
  self:add(self.player)
  
  if state[index] then
    state.loadEnemies(self)
    state.loadDecals(self)
  else
    self.decals:loadFromXML(self.xml)
    self:loadEnemies(obj)
  end
  
  self:loadObjects(obj)
  self:loadTiledObjects(self.xml)
  
  self:setupLayers{
    [1] = { 1, pre = postfx.exclude, post = postfx.include }, -- walls
    [2] = 1, -- crosshair
    [3] = 1, -- player
    [4] = 1, -- enemies
    [5] = 1, -- projectiles
    [10] = 1 -- floor
  }
  
  state.saveEntrance(self)
end

function Level:loadEnemies(o)
  if not o then return end
  
  for _, v in ipairs(findChildren(o, "mauler")) do
    self:add(Mauler:fromXML(v))
  end
  
  for _, v in ipairs(findChildren(o, "floater")) do
    self:add(Floater:fromXML(v))
  end
  
  for _, v in ipairs(findChildren(o, "pod")) do
    self:add(Pod:fromXML(v))
  end
end

function Level:loadObjects(o)
  if not o then return end
  
  for _, v in ipairs(findChildren(o, "transitionZone")) do
    self:add(TransitionZone:fromXML(v))
  end
  
  for _, v in ipairs(findChildren(o, "textZone")) do
    self:add(TextZone:fromXML(v))
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

function Level:loadTiledObjects(xml)
  local o = findChild(self.xml, "tiledObjects")
  if not o then return end
  
  for _, v in ipairs(findChildren(o, "door")) do
    self:add(Door:fromXML(v))
  end
end
