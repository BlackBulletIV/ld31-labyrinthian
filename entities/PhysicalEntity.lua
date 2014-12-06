PhysicalEntity = class("PhysicalEntity", Entity)

function PhysicalEntity:initialize(x, y, width, height, type)
  Entity.initialize(self, x, y)
  self.width = width
  self.height = height
  self.type = type or "dynamic"
  self.velx = 0
  self.vely = 0
  self.gravityMult = 1
end

function PhysicalEntity:added()
  self.world._physicalEntities:push(self)
end

function PhysicalEntity:removed()
  self.world._physicalEntities:remove(self)
end

function PhysicalEntity:update(dt)
  if self.type == "static" then return end
  self.inAir = not self:collide(self.x, self.y + math.sign(self.gravityMult))
  if self.inAir then self.vely = self.vely + GRAVITY * self.gravityMult * dt end
  
  self.velx = self.velx * FRICTION * dt
  self:moveBy(self.velx * dt, self.vely * dt)
end

function PhysicalEntity:collide(x, y, type)
  x = x or self.x
  y = y or self.y
  type = type or "static"
  
  for e in self.world._physicalEntities:iterate() do
    if e ~= self and (type == "all" or type == e.type)
    and x + self.width > e.x
    and y + self.height > e.y
    and x < e.x + e.width
    and y < e.y + e.height
    then
      return e
    end
  end
  
  return false
end

function PhysicalEntity:moveBy(x, y, type, precision)
  type = type or "static"
  precision = precision or 2
    
  if x ~= 0 then
    if self:collide(self.x + x, self.y, type) then
      for e in self.world._physicalEntities:iterate() do
        local sign = math.sign(x) / precision
        
        while x ~= 0 do
          entity = self:collide(self.x + sign, self.y, type)
          
          if entity and self:collideX(entity) then
            break
          else
            self.x = self.x + sign
          end
          
          x = x - sign
        end
      end
    else
      self.x = self.x + x
    end
  end
  
  if y ~= 0 then
    if self:collide(self.x, self.y + y, type) then
      for e in self.world._physicalEntities:iterate() do
        local sign = math.sign(y) / precision
        
        while y ~= 0 do
          entity = self:collide(self.x, self.y + sign, type)
          
          if entity and self:collideY(entity) then
            break
          else
            self.y = self.y + sign
          end
          
          y = y - sign
        end
      end
    else
      self.y = self.y + y
    end
  end
  
  --self.x = math.round(self.x)
  --self.y = math.round(self.y)
end

function PhysicalEntity:collideX(entity)
  self.velx = 0
  return true
end

function PhysicalEntity:collideY(entity)
  self.vely = 0
  return true
end
