require("lib.ammo")
--require("lib.physics")
require("lib.assets")
require("lib.input")
require("lib.tweens")
require("lib.gfx")

slaxml = require("slaxdom")
require("misc.xmlUtils")
require("misc.utils")

require("entities.PhysicalEntity")
require("entities.Player")
require("entities.Floor")
require("entities.CollisionRect")
require("worlds.Level")

TILE_SIZE = 9
GRAVITY = 850
FRICTION = 50

function love.load()
  assets.loadFont("uni05.ttf", { 24, 16, 8 }, "main")
  
  assets.loadImage("tiles.png")
  assets.loadImage("player.png")
  for _, v in pairs(assets.images) do v:setFilter("nearest", "nearest") end
  
  input.define("left", "a", "left")
  input.define("right", "d", "right")
  input.define("jump", "w", "up", " ")
  input.define{"fire", mouse = "l"}
  input.define("flip", "f")
  input.define("quit", "escape")
  
  postfx.init()
  postfx.scale = 2
  love.graphics.width = love.graphics.width / 2
  love.graphics.height = love.graphics.height / 2
  ammo.world = Level:new(1)
end

function love.update(dt)
  postfx.update(dt)
  ammo.update(dt)
  if input.pressed("quit") then love.event.quit() end
  input.update()
end

function love.draw()
  postfx.start()
  ammo.draw()
  postfx.stop()
end
