local server = {}

server.bump = require "bump"

function server.start()
  server_data = {}
  server_data.lovernet = lovernetlib.new({type=lovernetlib.mode.server,port=default_port})

  if server_data.lovernet then

    server_data.lovernet._reset_player = function(user)
      user.x = math.random(-3,3)
      user.y = math.random(-3,3)
      user.angle = math.random()*math.pi*2
      user.hp = max_health
      user.dead = nil -- respawn timer on server
      user.killed_by = nil
      user.bullets = max_bullets
    end

    server.world = server.bump.newWorld(50)

    for i,v in pairs(map) do
      server.world:add({},v.x-0.5,v.y-0.5,1,1)
    end

    require("define")(server_data.lovernet)
  else
    server_data = nil
  end

end

function server.stop()
  server_data.lovernet:disconnect()
  server_data = nil
end

function server.draw()

  if debug_mode then

    love.graphics.print(
      "Server hosting on: " ..
        server_data.lovernet:getIp()..":"..server_data.lovernet:getPort())

    if client_data then

      local offx = love.graphics.getWidth()/2-32
      local offy = love.graphics.getHeight()/2-32

      for i,v in pairs(map) do
        love.graphics.rectangle("line",(v.x-0.5)*32+offx,(v.y-0.5)*32+offy,32,32)
      end

      for i,v in pairs(client_data.lovernet:getCache('p')) do
        love.graphics.print(v.name.."["..v.m..","..v.s..","..v.a.."]",
          v.x*32+16+2+offx,
          v.y*32-love.graphics.getFont():getHeight()/2+offy
        )
        love.graphics.circle("line",v.x*32+offx,v.y*32+offy,16)
        love.graphics.arc("line",v.x*32+offx,v.y*32+offy,16,v.a+0.2,v.a-0.2)
      end

      for i,v in pairs(server_data.lovernet:getStorage().bullets or {}) do
        love.graphics.circle("line",v.x*32+offx,v.y*32+offy,4)
        love.graphics.arc("line",v.x*32+offx,v.y*32+offy,16,v.angle+0.2,v.angle-0.2)
      end

    end

  end

end

local distance = function(a,b)
  return math.sqrt( (a.x - b.x)^2 + (a.y - b.y)^2 )
end

function server.update(dt)
  server_data.lovernet:update(dt)

  local speed = 10

  local bullets = server_data.lovernet:getStorage().bullets or {}

  for ibullet,bullet in pairs(bullets) do
    bullet.x = bullet.x + math.cos(bullet.angle)*speed*dt
    bullet.y = bullet.y + math.sin(bullet.angle)*speed*dt

    bullet.age = bullet.age - dt

    local hit_wall = false
    local ix = math.floor(bullet.x+0.5)
    local iy = math.floor(bullet.y+0.5)
    for _,tile in pairs(map) do
      if tile.x == ix and tile.y == iy then
        hit_wall = true
        break
      end
    end

    local hit_player = false
    for _,user in pairs(server_data.lovernet:getUsers()) do
      if bullet.owner ~= user then
        if distance(bullet,user) < 0.4 then
          hit_player = true
          user.hp = bullet.owner.boss and 0 or math.max(0, (user.hp or max_health) - 1)
          if user.hp == 0 and not user.killed_by then
            user.killed_by = bullet.owner
            -- lol ternary, eat your heart out
            bullet.owner.points = (bullet.owner.points or 0) + (
              bullet.owner.boss and 1 or (
                user.boss and 10 or -1
              )
            )
            bullet.owner.kills = (bullet.owner.kills or 0) + 1
            user.deaths = (user.deaths or 0) + 1
            if user.boss then
              user.boss = nil
              bullet.owner.boss = true
            end
          end
          break
        end
      end
    end

    if bullet.age <= 0 or hit_wall or hit_player then
      table.remove(bullets,ibullet)
    end
  end

  local found_boss = false

  for _,user in pairs(server_data.lovernet:getUsers()) do

    if user.boss then
      found_boss = true
    end

    user.reload = (user.reload or 0) + dt
    if user.reload > respawn_bullets then
      user.bullets = max_bullets
    end

    if user.hp and user.hp <= 0 then
      user.dead = user.dead and user.dead - dt or 2
      if user.dead <= 0 then
        server_data.lovernet._reset_player(user)
      end
    end

    if user.x and user.y then

      if not server.world:hasItem(user) then
        server.world:add(user,user.x,user.y,0.8,0.8)
        --TODO remove disconnected users
      end

      speed = 4

      local ux,uy = 0,0

      if user.move ~= 0 then
        ux = ux + math.cos(user.angle)*speed*dt*user.move
        uy = uy + math.sin(user.angle)*speed*dt*user.move
      end
      if user.strafe ~= 0 then
        ux = ux + math.cos(user.angle+math.pi/2)*speed*dt*user.strafe
        uy = uy + math.sin(user.angle+math.pi/2)*speed*dt*user.strafe
      end

      user.x,user.y = server.world:move(user,user.x+ux-0.4, user.y+uy-0.4)
      user.x = user.x + 0.4
      user.y = user.y + 0.4

    end
  end

  if not found_boss then
    for i,v in pairs(server_data.lovernet:getUsers()) do
      v.boss = true
      break
    end
  end

end

return server
