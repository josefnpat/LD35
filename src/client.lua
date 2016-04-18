local client = {}

local calc_direction = function(angle)
  return math.floor(((angle+math.pi/8)/(math.pi*2))*8)%8+1
end

function client.start(args)

  client_data = {}

  client_data.hp_bar = love.graphics.newImage("assets/hp_bar.png")
  client_data.hp_bar:setFilter("nearest")
  client_data.hp_frame = love.graphics.newImage("assets/hp_frame.png")
  client_data.hp_frame:setFilter("nearest")

  client_data.shooting = 0

  client_data.bg = love.graphics.newImage("assets/bg.png")
  client_data.bg:setFilter("nearest")

  client_data.vividcast = require "vividcast"

  client_data.weapons = love.graphics.newImage("assets/sprites/weapons.png")
  client_data.weapons:setFilter("nearest")

  local all = love.image.newImageData("assets/sprites/sprites.png")

  local extract = function(quad)
    local s = love.image.newImageData(64,64)
    local x,y,w,h = quad:getViewport()
    s:paste(all,0,0,x,y,w,h)
    return love.graphics.newImage(s)
  end

  client_data.sprites = require "assets.sprites.sprites"(extract)

  client_data.level = client_data.vividcast.level.new()
  client_data.level:setMapCallback(function(x,y)
    for i,v in pairs(map) do
      if v.x == x and v.y == y then
        return 1
      end
    end
    return 0
  end)
  client_data.level:setRaycastRange( 100 )
  client_data.level:setRaycastResolution(1/16)

  local tile = client_data.vividcast.tile.new()
  tile:setTexture(love.graphics.newImage("assets/walls/wall.png"))
  tile:getTexture():setFilter("nearest","nearest")
  client_data.level:addTile{type=1,tile=tile}

  client_data.player = client_data.vividcast.entity.new()
  client_data.player:setX(0)
  client_data.player:setY(0)
  client_data.player:setAngle(0)

  local extract = function(quad)
    local s = love.image.newImageData(64,64)
    local x,y,w,h = quad:getViewport()
    s:paste(all,0,0,x,y,w,h)
    return love.graphics.newImage(s)
  end

  client_data.reload_anim = 0

  client_data.users = {}

  client_data.level:addEntity(client_data.player)

  client_data.level:setPlayer(client_data.player)

  music.menu:stop()
  music.game:play()

  client_data.name = args.name or default_username..math.random(1000,9999)

  client_data.move,client_data.strafe,client_data.angle = 0,0,0
  args.port = default_port
  args.transmitRate = 1/24

  -- Connects to localhost by default
  client_data.lovernet = lovernetlib.new(args)

  -- Just in case google ever hosts a server:
  -- client_data.lovernet = lovernetlib.new{ip="8.8.8.8"}

  -- Configure the lovernet instances the same way the server does
  require("define")(client_data.lovernet)

  -- Get version information
  client_data.lovernet:pushData("version")

  -- Send your name once
  client_data.lovernet:pushData("whoami",{name=client_data.name})

end

function client.stop()
  client_data.lovernet:disconnect()
  client_data = nil

  music.game:stop()
  music.game_intro:stop()
  music.menu:play()
end

t = 0

function client.update(dt)

  client_data.reload_anim = math.min(client_data.reload_anim + dt,respawn_bullets)

  if not music.game:isPlaying() then
    music.game_intro:play()
  end

  t = t + dt

  client_data.shooting = math.max(0,client_data.shooting-dt*4)

  client_data.move = 0
  client_data.move = client_data.move + ( love.keyboard.isDown("w") and 1 or 0 )
  client_data.move = client_data.move + ( love.keyboard.isDown("s") and -1 or 0 )

  client_data.strafe = 0
  client_data.strafe = client_data.strafe + ( love.keyboard.isDown("d") and 1 or 0 )
  client_data.strafe = client_data.strafe + ( love.keyboard.isDown("a") and -1 or 0 )

  local offset = love.mouse.getX() - love.graphics.getWidth() / 2
  local scale = (offset / (love.graphics.getWidth() / 2)) * 20

  if love.keyboard.isDown("q") then
    client_data.angle = client_data.angle - 0.1
  end
  if love.keyboard.isDown("e") then
    client_data.angle = client_data.angle + 0.1
  end

  if client_data.move ~= client_data.last_move or
    client_data.strafe ~= client_data.last_strafe or
    client_data.angle ~= client_data.last_angle then

    client_data.last_move = client_data.move
    client_data.last_strafe = client_data.strafe
    client_data.last_angle = client_data.angle

    client_data.lovernet:clearData('m')
    client_data.lovernet:pushData('m',{
      m=client_data.move,
      s=client_data.strafe,
      a=client_data.angle,
    })
  end

  if client_data.lovernet:getCache("p") then

    for i,v in pairs(client_data.lovernet:getCache("p")) do

      if v.c then --if current player

        if client_data.hp ~= v.hp then
          if client_data.hp == 0 then
            sfx.play(v.b and sfx.boss.spawn or sfx.player.spawn)
          else
            sfx.play(v.b and sfx.boss.hurt or sfx.player.hurt)
          end
        end
        client_data.hp = v.hp
        client_data.boss = v.boss
        client_data.bullets = v.b
        client_data.player:setX(v.x+0.4 or 0)
        client_data.player:setY(v.y+0.4 or 0)
        client_data.player:setAngle(v.a)
        client_data.dead = v.d == 1

        if client_data.points then
          if client_data.points + 1 == v.p then
            sfx.play(sfx.boss.kill)
          end
          if client_data.points - 1 == v.p then
            sfx.play(sfx.player.kill)
          end
          if client_data.points + 10 == v.p then
            --print("You killed dracula")
          end
        end
        client_data.points = v.p

      else

        -- Init other player
        if client_data.users[v.name] == nil then
          local dev = {}
          dev.ent = client_data.vividcast.entity.new()
          dev.ent:setTexture(function(this,angle)
            if this._dead then
              local index = math.min(math.floor(this._dead_dt),1)+1
              return client_data.sprites.death[index]
            else
              local dir = calc_direction(angle)
              if dir == 1 and this._shooting == 1 then
                return client_data.sprites.shoot[1][3]
              else
                if this._walking then
                  local index = math.floor(t*4)%#client_data.sprites.walk[1] + 1
                  return client_data.sprites.walk[dir][index]
                else
                  return client_data.sprites.stand[dir]
                end
              end
            end
          end)
          client_data.level:addEntity(dev.ent)
          client_data.users[v.name] = dev
          -- TODO: add move and strafe
        end
        client_data.users[v.name].ent:setX(v.x+0.4)
        client_data.users[v.name].ent:setY(v.y+0.4)
        client_data.users[v.name].ent:setAngle(v.a)
        client_data.users[v.name].ent._walking = v.m ~= 0 or v.s ~= 0
        client_data.users[v.name].ent._shooting = v.f
        if v.dead == 1 then
          client_data.users[v.name].ent._dead = true
          client_data.users[v.name].ent._dead_dt = (client_data.users[v.name].ent._dead_dt or 0) + dt*4
        else
          client_data.users[v.name].ent._dead = nil
          client_data.users[v.name].ent._dead_dt = nil
        end

        client_data.users[v.name].last_update = 0
      end

    end

  end

  for i,v in pairs(client_data.users) do
    v.last_update = (v.last_update or 0) + dt
    if v.last_update > 0.5 then
      client_data.users[i] = nil
      client_data.level:removeEntity(v.ent)
    end
  end
  client_data.level:removeEntity()


  -- Request a player list
  if not client_data.lovernet:hasData('p') then
    client_data.lovernet:pushData('p')
  end

  -- update the lovernet object
  client_data.lovernet:update(dt)

end

function client.draw()

  if not client_data.lovernet:isConnectedToServer() then

    love.graphics.print("CONNECTING:\n"..client_data.lovernet:getIp()..":"..client_data.lovernet:getPort(),0,0)

  elseif client_data.lovernet:getCache('version') ~= true then

    love.graphics.print(client_data.lovernet:getCache('version'),0,0)

  else

    love.graphics.draw(client_data.bg,0,0,0,scale,scale)
    if raycast_mode then
      client_data.level:draw(0,0,64*scale,64*scale,scale)
    end

    local shootindex = math.floor(client_data.shooting*5)+1

    local weaponindex = client_data.boss and 1 or (client_data.bullets == 0 and 1 or 2)

    love.graphics.draw(client_data.weapons,client_data.sprites.weapon_quads[weaponindex][shootindex],
      0,32*scale,0,scale,scale)

    love.graphics.setScissor(0,
      client_data.hp_bar:getHeight()*scale * (1 - ((client_data.hp or 0)/max_health)),
      client_data.hp_bar:getWidth()*scale,
      client_data.hp_bar:getHeight()*scale)
    love.graphics.draw(client_data.hp_bar,0,0,0,scale)
    love.graphics.setScissor( )
    love.graphics.draw(client_data.hp_frame,0,0,0,scale)

    if client_data.boss == true then
      love.graphics.print("DRACULA",0,(64-6)*10)
    else
      if client_data.bullets then
        if client_data.bullets > 0 then
          love.graphics.print(string.rep(".",client_data.bullets or 0),0,(64-6)*10)
        else
          local alpha = client_data.reload_anim/respawn_bullets*255
          love.graphics.setColor(255,255,255,alpha)
          love.graphics.print("RELOAD",0,(64-6)*10)
          love.graphics.setColor(255,255,255)
        end
      end
    end

    if client_data.hp and client_data.hp <= 0 then
      love.graphics.setColor(255,0,0,127)
      love.graphics.rectangle("fill",0,0,64*scale,64*scale)
    end

    if love.keyboard.isDown("tab") and client_data.lovernet:getCache('p') then
      love.graphics.setColor(0,0,0,191)
      love.graphics.rectangle("fill",0,0,love.graphics.getWidth(),love.graphics.getHeight())

      local players = client_data.lovernet:getCache('p')
      table.sort(players,function(a,b)
        return (a.p or 0) > (b.p or 0)
      end)

      for iuser,user in pairs(players) do
        if user.c then
          love.graphics.setColor(0,255,0)
        else
          love.graphics.setColor(255,255,255)
        end
        love.graphics.print((user.p or 0).."/"..user.k.."/"..user.d.." "..user.name,
          0,love.graphics.getFont():getHeight()*scale*(iuser-1))
      end
      love.graphics.setColor(255,255,255)
    end

  end

end

function client.mousemoved(x,y,dx,dy)
  if love.window.hasFocus() then
    client_data.angle = client_data.angle+dx/250
  end
end

function client.mousepressed(x,y,button)
  if not client_data.dead then
    -- copy paste
    local weaponindex = client_data.boss and 1 or (client_data.bullets == 0 and 1 or 2)

    sfx.play(sfx.weapon[weaponindex])
    client_data.shooting = 1
    client_data.reload_anim = 0
    client_data.lovernet:pushData('s')
  end
end

return client
