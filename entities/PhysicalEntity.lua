PhyiscalEntity = class("PhyiscalEntity", Entity)

function PhyiscalEntity:initialize(x, y, width, height, type)
  Entity.initialize(self, x, y)
  self.width = 0
  self.height = 0
  self.type = type or "dynamic"
  self.velx = 0
  self.vely = 0
  self.gravityMult = 1
end

function PhyiscalEntity:added()
  self.world._physicalEntities:push(self)
end

function PhyiscalEntity:removed()
  self.world._physicalEntities:remove(self)
end

function PhyiscalEntity:update(dt)
  self.inAir = self:collide(self.x, self.y + 1)
  if self.inAir then self.vely = self.vely + GRAVITY * self.gravityMult * dt end
  
  self.velx = self.velx * FRICTION * dt
  self:moveBy(self.velx * dt, self.vely * dt)
end

function PhyiscalEntity:collide(x, y, type)
  x = x or self.x
  y = y or self.y
  type = type or "static"
  
  for e in self.world._physicalEntities:iterate() do
    if e ~= self and (type == "all" or type == e.type)
    and x + self.width / 2 > e.x - self.width / 2
    and y + self.height / 2 > e.y - self.height / 2
    and x - self.width / 2 < e.x + self.width / 2
    and y - self.height / 2 < e.y + self.height / 2
    then
      return e
    end
  end
end

function PhyiscalEntity:moveBy(x, y, type)
  type = type or "static"
  
  if x ~= 0 then
    if self:collide(self.x + x, self.y, type) then
      for e in self.world._physicalEntities:iterate() do
        local sign = math.sign(x)
        
        while x ~= 0 do
          entity = self:collide(self.x + sign, self.y, type)
          
          if entity and self:collideX(entity) then
            break
          else
            self.x = self.x + sign
          end
          
          x -= sign
        end
      end
    else
      self.x = self.x + x
    end
  end
  
  if y ~= 0 then
    if self:collide(self.x, self.y + y, type) then
      for e in self.world._physicalEntities:iterate() do
        local sign = math.sign(y)
        
        while y ~= 0 do
          entity = self:collide(self.x, self.y + sign, type)
          
          if entity and self:collideY(entity) then
            break
          else
            self.y = self.y + sign
          end
          
          y -= sign
        end
      end
    else
      self.y = self.y + y
    end
  end
end

function PhyiscalEntity:collideX(entity)
  return true
end

function PhyiscalEntity:collideY(entity)
  return true
end
