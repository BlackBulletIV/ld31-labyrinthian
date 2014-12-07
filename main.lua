require("lib.ammo")
require("lib.physics")
require("lib.assets")
require("lib.input")
require("lib.tweens")
require("lib.gfx")

slaxml = require("slaxdom")
require("misc.xmlUtils")
require("misc.utils")
require("misc.lighting")

require("entities.Player")
require("entities.Enemy")
require("entities.Mauler")
require("entities.Walls")
require("entities.Floor")
require("entities.Bullet")
require("entities.Crosshair")
require("entities.TransitionZone")
require("worlds.Level")

TILE_SIZE = 9

function love.load()
  assets.loadFont("uni05.ttf", { 24, 16, 8 }, "main")
  assets.loadShader("lighting-composite.frag", "lightingComposite")
  
  assets.loadImage("crosshair.png")
  assets.loadImage("tiles.png")
  assets.loadImage("player.png")
  assets.loadImage("mauler.png")
  assets.loadImage("bullet.png")
  assets.loadImage("muzzle-flash.png", "muzzleFlash")
  for _, v in pairs(assets.images) do v:setFilter("nearest", "nearest") end
  
  input.define("left", "a", "left")
  input.define("right", "d", "right")
  input.define("up", "w", "up")
  input.define("down", "s", "down")
  input.define{"fire", mouse = "l"}
  input.define("torch", "f")
  input.define("quit", "escape")
  
  postfx.init()
  postfx.scale = 2
  lighting:init()
  postfx.add(lighting)
  love.graphics.width = love.graphics.width / 2
  love.graphics.height = love.graphics.height / 2
  love.mouse.setVisible(false)
  love.mouse.setGrabbed(true)
  
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
