state = {}

function state.savePlayer()
  local p = ammo.world.player
  state.player = { torch = {} }
  state.player.x = p.x
  state.player.y = p.y
  state.player.velx = p.velx
  state.player.vely = p.vely
  state.player.torchOn = p.torchOn
  state.player.torch.alpha = p.torch.alpha
  state.player.torch.angle = p.torch.angle
end

function state.saveEntrance(world)
  state.entrance = world.player.pos / 1
end

function state.saveLevel()
  local t = {}
  t.decals = ammo.world.decals
  t.enemies = {}
  
  for e in ammo.world:iterate() do
    if instanceOf(Enemy, e) then
      if not e.dead then
        t.enemies[#t.enemies + 1] = {
          type = e.class.name,
          x = e.x,
          y = e.y,
          angle = e.angle,
          patrol = e.patrol
        }
      end
    elseif instanceOf(Pod, e) then
      t.enemies[#t.enemies + 1] = {
        type = "Pod",
        x = e.x,
        y = e.y,
        angle = e.angle,
        bursted = e.bursted
      }
    end
  end
  
  state[ammo.world.index] = t
end

function state.loadEnemies(world)
  local st = state[world.index]
  local o
  
  for _, v in ipairs(st.enemies) do
    if v.type == "Pod" then
      o = Pod:new(v.x, v.y)
      o.angle = v.angle
      o.bursted = v.bursted
      world:add(o)
    else
      o = _G[v.type]:new(v.x, v.y)
      o.angle = v.angle
      o.patrol = v.patrol
      world:add(o)
    end
  end
end

function state.loadDecals(world)
  local st = state[world.index]
  world.decals.canvas = st.decals
end

function state.createPlayer()
  local pl = state.player
  o = Player:new(pl.x, pl.y)
  o.velx = pl.velx
  o.vely = pl.vely
  o.torchOn = pl.torchOn
  o.torch.alpha = pl.torch.alpha
  o.torch.angle = pl.torch.angle
  o.torchGlow.alpha = pl.torch.alpha
  o.torchGlow.angle = pl.torch.angle
  return o
end

function state.resetLevels()
  for i = 1, 99 do state[i] = nil end
end
