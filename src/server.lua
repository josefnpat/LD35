local server = {}

server.bump = require "bump"

function server.start()
  server_data = {}
  server_data.lovernet = lovernetlib.new({type=lovernetlib.mode.server,port=3535})

  server.world = server.bump.newWorld(50)

  for i,v in pairs(map) do
    server.world:add({},v.x-0.5,v.y-0.5,1,1)
  end

  if server_data.lovernet then
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

  end
end

function server.update(dt)
  server_data.lovernet:update(dt)

  for _,user in pairs(server_data.lovernet:getUsers()) do
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
end

return server
