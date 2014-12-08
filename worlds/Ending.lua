Ending = class("Ending", World)

function Ending:initialize()
  World.initialize(self)
  lighting.active = false
end

function Ending:start()
  fade.tween:stop()
  fade.alpha = 0
  delay(1, text.display, 2, "Subject has escaped")
  delay(4, text.display, 3, "Sending all available personnel")
  delay(9, function() ammo.world = Intro:new() end)
end
