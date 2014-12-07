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
require("misc.noise")
require("misc.state")
require("misc.fade")
require("misc.text")

require("entities.Player")
require("entities.Enemy")
require("entities.Mauler")
require("entities.Walls")
require("entities.Floor")
require("entities.Bullet")
require("entities.Crosshair")
require("entities.TransitionZone")
require("entities.Pod")
require("entities.Spider")
require("entities.Floater")
require("entities.VaporShot")
require("entities.Door")
require("entities.TextZone")
require("entities.Decals")
require("worlds.Level")

TILE_SIZE = 9

function love.load()
  assets.loadFont("uni05.ttf", { 24, 16 }, "main")
  assets.loadShader("lighting-composite.frag", "lightingComposite")
  assets.loadShader("noise.frag")
  
  assets.loadImage("crosshair.png")
  assets.loadImage("particle.png")
  assets.loadImage("tiles.png")
  assets.loadImage("player.png")
  assets.loadImage("player-death.png", "playerDeath")
  assets.loadImage("mauler.png")
  assets.loadImage("floater.png")
  assets.loadImage("pod.png")
  assets.loadImage("spider.png")
  assets.loadImage("bullet.png")
  assets.loadImage("muzzle-flash.png", "muzzleFlash")
  assets.loadImage("vapor-shot.png", "vaporShot")
  assets.loadImage("door.png")
  for _, v in pairs(assets.images) do v:setFilter("nearest", "nearest") end
  
  assets.loadSfx("bg.ogg")
  assets.loadSfx("shoot1.ogg", 0.8)
  assets.loadSfx("shoot2.ogg", 0.8)
  assets.loadSfx("shoot3.ogg", 0.8)
  assets.loadSfx("step1.ogg", 0.5)
  assets.loadSfx("step2.ogg", 0.5)
  assets.loadSfx("step3.ogg", 0.5)
  assets.loadSfx("step4.ogg", 0.5)
  assets.loadSfx("mauler-step1.ogg", "maulerStep1")
  assets.loadSfx("mauler-step2.ogg", "maulerStep2")
  assets.loadSfx("mauler-step3.ogg", "maulerStep3")
  assets.loadSfx("mauler-step4.ogg", "maulerStep4")
  assets.loadSfx("mauler-lunge.ogg", "maulerLunge")
  assets.loadSfx("floater-idle.ogg", "floaterIdle", 1)
  assets.loadSfx("floater-alert.ogg", "floaterAlert", 1)
  assets.loadSfx("floater-death1.ogg", "floaterDeath1")
  assets.loadSfx("floater-death2.ogg", "floaterDeath2")
  assets.loadSfx("floater-shoot1.ogg", "floaterShoot1")
  assets.loadSfx("floater-shoot2.ogg", "floaterShoot2")
  assets.loadSfx("floater-shoot3.ogg", "floaterShoot3")
  assets.loadSfx("pod-burst1.ogg", "podBurst1")
  assets.loadSfx("pod-burst2.ogg", "podBurst2")
  assets.loadSfx("spider-death1.ogg", "spiderDeath1")
  assets.loadSfx("spider-death2.ogg", "spiderDeath2")
  assets.loadSfx("torch.ogg")
  
  input.define("left", "a", "left")
  input.define("right", "d", "right")
  input.define("up", "w", "up")
  input.define("down", "s", "down")
  input.define{"fire", mouse = "l"}
  input.define("torch", "f")
  input.define("quit", "escape")
  
  input.define("pause", "p")
  input.define("prev", "-")
  input.define("next", "=")
  
  postfx.init()
  postfx.scale = 2
  lighting:init()
  postfx.add(lighting)
  postfx.add(noise)
  
  love.graphics.width = love.graphics.width / 2
  love.graphics.height = love.graphics.height / 2
  love.mouse.setVisible(false)
  love.mouse.setGrabbed(true)
  
  bgSfx = assets.sfx.bg:loop()
  ammo.world = Level:new(1)
  paused = false
end

function love.update(dt)
  if not paused then
    fade.update(dt)
    text.update(dt)
    postfx.update(dt)
    ammo.update(dt)
    
    if input.pressed("prev") then ammo.world = Level:new(ammo.world.index - 1) end
    if input.pressed("next") then ammo.world = Level:new(ammo.world.index + 1) end
  end
  
  if input.pressed("pause") then paused = not paused end
  if input.pressed("quit") then love.event.quit() end
  input.update()
end

function love.draw()
  postfx.start()
  ammo.draw()
  postfx.stop()
  text.draw()
  fade.draw()
end
