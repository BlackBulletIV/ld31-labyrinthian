Intro = class("Intro", World)

function Intro:initialize()
  World.initialize(self)
  lighting.active = false
  fade.alpha = 255
  fade.into()
  
  self.title = Text:new{"Labyrinthian", x = 0, y = love.graphics.height / 4, width = love.graphics.width, align = "center", font = assets.fonts.main[24] }
  self.instructions = Text:new{"Enter to start\nWASD to move\nF to toggle torch\nLMB to shoot", x = 0, y = love.graphics.height / 2, align = "center", font = assets.fonts.main[8] }
end

function Intro:update(dt)
  if input.key.pressed["return"] then
    fade.out(function()
      ammo.world = Level:new(1)
      fade.into(0.01)
    end)
  end
end

function Intro:draw()
  self.title:draw()
  self.instructions:draw()
end
