EndZone = class("EndZone", TransitionZone)

function EndZone.static:fromXML(e)
  local w, h = tonumber(e.attr.width), tonumber(e.attr.height)
  
  return EndZone:new(
    tonumber(e.attr.x) + w / 2,
    tonumber(e.attr.y) + h / 2,
    w,
    h,
    math.rad(tonumber(e.attr.facing)),
    e.attr.restart == "1"
  )
end

function EndZone:initialize(x, y, width, height, facing, restart)
  TransitionZone.initialize(self, x, y, width, height, nil, facing)
  self.restart = restart
end

function EndZone:transition()
  self.transitioned = true
  state.resetLevels()
  
  if self.restart then
    ammo.world = Level:new(1)
  else
    fade.out(function() ammo.world = Ending:new() end)
  end
end
