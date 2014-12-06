Level = class("Level", PhysicalWorld)
Level.static.list = { "1" }

function Level:initialize(index)
  PhysicalWorld.initialize(self)
  local xmlFile = love.filesystem.read("assets/levels/" .. Level.list[index] .. ".oel")
  self.xml = slaxml:dom(xmlFile).root
  self.width = getText(self.xml, "width")
  self.height = getText(self.xml, "height")
  self._physicalEntities = LinkedList:new("_physNext", "_physPrev")
  
  self.floor = Floor:new(self.xml, self.width, self.height)
  self:add(self.floor)
  self:loadObjects()  
  
  self:setupLayers{
    [1] = 1, -- floor
    [3] = 1, -- player
    [10] = 1 -- walls
  }
  
  --self:setGravity(0, 500)
end

function Level:loadObjects()
  local o = findChild(self.xml, "objects")
  self.player = Player:fromXML(findChild(o, "player"))
  self:add(self.player)
end
