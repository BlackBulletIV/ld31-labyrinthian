noise = {}
noise.active = true

function noise:init()
  self.supported = postfx.fxSupported
  self.timer = 0
  self.time = 0.04
  self.effect = assets.shaders.noise
end

function noise:update(dt)
  if self.timer >= self.time then
    -- a 2d random factor seems to reduce the size of the occasional "artifacts"
    self.effect:send("factor", { math.random(), math.random() })
    self.timer = self.timer - self.time
  end
  
  self.timer = self.timer + dt
end

function noise:draw(canvas, alternate)
  love.graphics.setShader(self.effect)
  love.graphics.setCanvas(alternate)
  love.graphics.draw(canvas, 0, 0)
  
  canvas:clear()
  love.graphics.setCanvas(canvas)
  love.graphics.draw(postfx.exclusion, 0, 0)
  love.graphics.setShader()
  
  postfx.exclusion:clear()
  love.graphics.setCanvas(postfx.exclusion)
  love.graphics.draw(canvas, 0, 0)
  
  postfx.swap()
end
