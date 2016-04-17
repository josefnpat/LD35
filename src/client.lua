local client = {}

function client.start(args)

  client_data = {}

  client_data.bg = love.graphics.newImage("assets/bg.png")
  client_data.bg:setFilter("nearest")

  client_data.vividcast = require "vividcast"

  local all = love.image.newImageData("assets/sprites/sprites.png")

  local extract = function(quad)
    local s = love.image.newImageData(64,64)
    local x,y,w,h = quad:getViewport()
    s:paste(all,0,0,x,y,w,h)
    return love.graphics.newImage(s)
  end

  client_data.sprites = require "assets.sprites.sprites"(extract)

  all  = nil

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

  local calc_direction = function(angle)
    return math.floor(((angle+math.pi/8)/(math.pi*2))*8)%8+1
  end

  dev = {}
  dev.ent = client_data.vividcast.entity.new()
  dev.ent:setX(1)
  dev.ent:setY(0)
  dev.ent:setAngle(1)
  dev.ent:setTexture(function(this,angle)
    return client_data.sprites.stand[calc_direction(angle)]
  end)

  client_data.level:addEntity(dev.ent)

  client_data.level:addEntity(client_data.player)

  client_data.level:setPlayer(client_data.player)

  music.menu:stop()
  music.game:play()

  client_data.name = args.name or "Peasant"..math.random(1000,9999)

  client_data.move,client_data.strafe,client_data.angle = 0,0,0
  args.port = "3535"
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
  music.menu:play()
end

function client.update(dt)

  client_data.move = 0
  client_data.move = client_data.move + ( love.keyboard.isDown("w") and 1 or 0 )
  client_data.move = client_data.move + ( love.keyboard.isDown("s") and -1 or 0 )

  client_data.strafe = 0
  client_data.strafe = client_data.strafe + ( love.keyboard.isDown("d") and 1 or 0 )
  client_data.strafe = client_data.strafe + ( love.keyboard.isDown("a") and -1 or 0 )

  local offset = love.mouse.getX() - love.graphics.getWidth() / 2
  local scale = (offset / (love.graphics.getWidth() / 2)) * 20
  use_mouse = love.window.hasFocus()
  if use_mouse then
    client_data.angle = client_data.angle + scale*dt
    love.mouse.setX(love.graphics.getWidth() / 2)
  end

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
        client_data.player:setX(v.x+0.4 or 0)
        client_data.player:setY(v.y+0.4 or 0)
        client_data.player:setAngle(v.a)
      end
    end
  end




  -- TODO: add delay timer
  -- Request a player list
  if not client_data.lovernet:hasData('p') then
    client_data.lovernet:pushData('p')
  end

  -- update the lovernet object
  client_data.lovernet:update(dt)

end

function client.draw()

  if not client_data.lovernet:isConnectedToServer() then

    love.graphics.printf(
      "Connecting to "..client_data.lovernet:getIp()..":"..client_data.lovernet:getPort(),
      0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")

  elseif client_data.lovernet:getCache('version') ~= true then

    love.graphics.printf(
      client_data.lovernet:getCache('version'),
      0,love.graphics.getHeight()/2,love.graphics.getWidth(),"center")

  else

    love.graphics.draw(client_data.bg,0,0,0,scale,scale)
    client_data.level:draw(0,0,64*scale,64*scale,scale)

  end

end

return client
