function getMouse()
  return love.mouse.getX() / postfx.scale, love.mouse.getY() / postfx.scale
end

local function soundVals(x, y, volume, pan)
  local player = ammo.world.player
  volume = (volume or 1 ) * math.clamp(math.scale(math.distance(x, y, player.x, player.y), 300, 10, 0, 1), 0, 1)
  
  local angle = math.angle(x, y, player.x, player.y)
  local dot = Vector(math.cos(angle), math.sin(angle)):normalize() * Vector(math.cos(player.angle), math.sin(player.angle)):normalize()
  pan = (1 - math.abs(dot)) * (pan or 1)
  
  return volume, pan
end

function playSound(sound, x, y, volume, pan)
  if type(sound) == "string" then sound = assets.sfx[sound] end
  if x then volume, pan = soundVals(x, y, volume, pan) end
  
  return sound:play(volume, pan)
end

function playRandom(sounds, x, y, volume, pan)
  return playSound(sounds[math.random(1, #sounds)], x, y, volume, pan)
end

function updateSound(sound, x, y, volume, pan)
  local volume, pan = soundVals(x, y, volume, pan)
  sound:setVolume(volume)
  sound:setPosition(pan, 0, 0)
end

function Entity:drawImage(image, x, y, ox, oy)
  image = image or self.image
  if self.color then love.graphics.setColor(self.color) end
  
  love.graphics.draw(
    image,
    x or self.x,
    y or self.y,
    self.angle,
    self.scaleX or self.scale or 1,
    self.scaleY or self.scale or 1,
    ox or image:getWidth() / 2,
    oy or image:getHeight() / 2
  )
end

function Entity:playSound(sound, volume, pan)
  return playSound(sound, self.x, self.y, volume, pan)
end

function Entity:playRandom(sounds, volume, pan)
  return playRandom(sounds, self.x, self.y, volume, pan)
end
