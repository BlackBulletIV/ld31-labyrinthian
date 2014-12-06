require("lib.ammo")
require("lib.physics")
require("lib.assets")
require("lib.input")
require("lib.tweens")
require("lib.gfx")

TILE_SIZE = 9

function love.load()
  
end

function love.update(dt)
  ammo.update(dt)
end

function love.draw()
  ammo.draw()
end
