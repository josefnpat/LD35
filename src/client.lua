local client = {}

function client.start(args)

  music.menu:stop()
  music.game:play()

  client_data = {}

  client_data.name = args.name or "Peasant"..math.random(1000,9999)

  client_data.move,client_data.strafe,client_data.angle = 0,0,0
  args.port = "3535"

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
  use_mouse = true
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

    love.graphics.setColor(255,255,255)

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

  end

end

return client
