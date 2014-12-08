lighting = {}
lighting.active = true

-- negative = visible to light; positive = not visible
local function edgeNormal(lx, ly, x1, y1, x2, y2)
  -- cross product
  local cx = y1 - y2
  local cy = -(x1 - x2)
  return math.dot(cx, cy, (x1 + x2) / 2 - lx, (y1 + y2) / 2 - ly) -- the edge normal
end

local function drawShadow(lx, ly, p)
  local prevNormal = edgeNormal(lx, ly, p[#p - 1], p[#p], p[1], p[2])
  local points = {}
  local start, stop
  local direction = 1
  
  -- find the start and stop points
  -- they can be opposite each other depending in the light's position, and the order of the points
  for i = 1, #p, 2 do
    local normal = edgeNormal(lx, ly, p[i], p[i + 1], p[i + 2] or p[1], p[i + 3] or p[2])
    
    if normal < 0 and prevNormal >= 0 then
      -- was visible, now isn't; start the shadow
      start = i
    elseif normal >= 0 and prevNormal < 0 then
      -- wasn't visible, now is; end the shadow
      stop = i
      if not start then direction = -1 end
    end
    
    if start and stop then break end
    prevNormal = normal
  end
    
  if start and stop then
    local count = math.abs(stop - start) + 2
    
    -- loop through the range of points hidden from the light
    for i = start, stop, 2 * direction do
      local x, y = p[i], p[i + 1]
      local angle = math.angle(lx, ly, x, y)
      
      -- if it's the starting point, it must go before the projected points
      --[[if i == start then
        points[#points + 1] = x
        points[#points + 1] = y
      end]]
      
      local pi = math.abs(i - start) + 1 -- points index
      points[pi] = x
      points[pi + 1] = y
      points[count * 2 - pi] = x + math.cos(angle) * lighting.projectLength
      points[count * 2 - pi + 1] = y + math.sin(angle) * lighting.projectLength
      -- if it's the stopping point, it must go after
      --[[if i == stop then
        points[#points + 1] = x
        points[#points + 1] = y
      end]]
    end
    
    -- the number of points is generally less than 3 then the light is on top of the polygon
    if #points >= 6 then
      love.graphics.setColor(255, 255, 255, lighting.ambient)
      love.graphics.polygon("fill", unpack(points))
      
      --[[for i = 1, #points, 2 do
        love.graphics.pushColor(255, 0, 0)
        love.graphics.setPointSize(5)
        love.graphics.point(points[i], points[i + 1])
        love.graphics.popColor()
      end]]
    end
  end
end

local function makeLightImage(radius, inner, intensity)
  local data = love.image.newImageData(radius * 2, radius * 2)
  inner = inner or 0
  intensity = intensity or 1
  
  data:mapPixel(function(x, y)
    local dist = math.distance(radius, radius, x, y)
    return 0, 0, 0, (dist <= radius and math.min(255 * intensity, math.scale(dist, inner, radius, 255 * intensity, 0)) or 0)
  end)
  
  return love.graphics.newImage(data)
end

local function makeBeamImage(range, spread, inner, intensity)
  local midHeight = math.tan(spread) * range
  local data = love.image.newImageData(range * 2, midHeight * 2)
  inner = inner or 0
  intensity = intensity or 1
  
  data:mapPixel(function(x, y)
    local alpha
    local angle = math.angle(range, midHeight, x, y)
    
    if angle > spread and angle < (math.tau - spread) then
      alpha = 0
    else
      
      local dist = math.distance(range, midHeight, x, y)
      if angle > spread then angle = angle - math.tau end
      local angleScale = math.min(math.scale(math.abs(angle), spread * 0.3, spread, 1, 0), 1)
      alpha = dist <= range and math.min(255 * intensity, math.scale(dist, inner, range, 255 * intensity, 0)) * angleScale or 0
    end
    
    return 0, 0, 0, alpha
  end)
  
  return love.graphics.newImage(data)
end

function lighting:init()
  self.lights = LinkedList:new()
  self.canvas = love.graphics.newCanvas()
  self.lightCanvas = love.graphics.newCanvas()
  self.projectLength = 2000
  self.ambient = 255
end

function lighting:draw(canvas, alternate)
  self.canvas:clear(self.ambient, self.ambient, self.ambient)
  --if not ammo.world.walls then return end
  
  for light in self.lights:iterate() do
    if light.alpha > 0 then
      local lx, ly = light.x, light.y
      self.lightCanvas:clear()
      love.graphics.setCanvas(self.lightCanvas)
      love.graphics.setColor(255, 255, 255, light.alpha)
      
      if light.type == "beam" then
        love.graphics.draw(light.image, lx, ly, light.angle, 1, 1, light.range, light.midHeight)
      else
        love.graphics.draw(light.image, lx - light.radius, ly - light.radius)
      end
      
      love.graphics.setColor(255, 255, 255, 255)
      
      love.graphics.setBlendMode("subtractive")
      local fixtures = ammo.world.walls:getFixtureList()
      love.graphics.storeColor()
      
      for _, f in ipairs(fixtures) do
        local points = { f:getShape():getPoints() }
        drawShadow(lx, ly, points)
      end
      
      love.graphics.resetColor()
      
      love.graphics.setBlendMode("alpha")
      love.graphics.setCanvas(self.canvas)
      love.graphics.draw(self.lightCanvas, 0, 0)
    end
  end
  
  love.graphics.setBlendMode("alpha")
  love.graphics.setCanvas(alternate)
  love.graphics.setShader(assets.shaders.lightingComposite)
  assets.shaders.lightingComposite:send("lighting", self.canvas)
  love.graphics.draw(canvas, 0, 0)
  love.graphics.setShader()
  postfx.swap()
end

function lighting:addLight(x, y, radius, innerRadius, intensity)
  local t = {
    x = x,
    y = y,
    alpha = 255,
    radius = radius,
    image = makeLightImage(radius, innerRadius, intensity),
    type = "circle"
  }
  
  self.lights:push(t)
  return t
end

function lighting:addBeam(x, y, angle, range, spread, innerRadius, intensity)
  local t = {
    x = x,
    y = y,
    angle = angle,
    alpha = 255,
    range = range,
    midHeight = math.tan(spread) * range,
    image = makeBeamImage(range, spread, innerRadius, intensity),
    type = "beam"
  }
  
  self.lights:push(t)
  return t
end

function lighting:removeLight(t)
  self.lights:remove(t)
end

function lighting:clear()
  self.lights:clear()
end
