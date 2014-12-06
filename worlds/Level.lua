Level = class("Level", PhysicalWorld)
Level.static.list = { "1" }

function Level:initialize(index)
  PhysicalWorld.initialize(self)
  local xmlFile = love.filesystem.read("assets/levels/" .. Level.list[index] .. ".oel")
  self.xml = slaxml:dom(xmlFile).root
  self.width = getText(self.xml, "width")
  self.height = getText(self.xml, "height")
    
  self.walls = Walls:new(self.xml, self.width, self.height)
  self:add(self.walls)
  self:loadObjects()  
  
  self:setupLayers{
    [1] = 1, -- walls
    [3] = 1, -- player
    [10] = 1 -- floor
  }
  
end

function Level:loadObjects()
  local o = findChild(self.xml, "objects")
  self.player = Player:fromXML(findChild(o, "player"))
  self:add(self.player)
end
