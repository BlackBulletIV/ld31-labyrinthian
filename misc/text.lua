text = {}
text.content = nil
text.time = 0
text.timer = 0
text.alpha = 0
text.fadeTime = 0.2

function text.update(dt)
  if text.tween and text.tween.active then text.tween:update(dt) end
  
  if text.timer > 0 then
    text.timer = text.timer - dt
    print(text.timer)
  elseif text.timer ~= -2 then
    text.timer = -2
    text.fadeOut(function() text.content = nil end)
  end
end

function text.draw()
  if text.content then
    love.graphics.storeColor()
    love.graphics.setColor(255, 255, 255, text.alpha)
    love.graphics.setFont(assets.fonts.main[16])
    love.graphics.printf(text.content, love.graphics.width / 16 * 2, love.graphics.height * (2/3) * 2, love.graphics.width * (14/16) * 2, "center")
    love.graphics.resetColor()
  end
end

function text.display(time, t)
  if text.content then
    text.fadeOut(function()
      text.time = time
      text.timer = time
      text.content = t
      text.fadeIn()
    end)
  else
    text.time = time
    text.timer = time
    text.content = t
    text.fadeIn()
  end
end

function text.fadeIn(complete)
  text.tween = AttrTween:new(text, text.fadeTime, { alpha = 255 }, nil, complete)
  text.tween:start()
end

function text.fadeOut(complete)
  text.tween = AttrTween:new(text, text.fadeTime, { alpha = 0 }, nil, complete)
  text.tween:start()
end
  
