function love.load()
  offx,offy =0,0
  map = require 'map'
end

function love.draw()
  for _,v in pairs(map) do
    love.graphics.circle("line",v.x*32-offx,v.y*32-offy,16)
  end
  love.graphics.line(0,-offy,love.graphics.getWidth(),-offy)
  love.graphics.line(-offx,0,-offx,love.graphics.getHeight())
end

function love.update(dt)
  speed = 100
  if love.keyboard.isDown("left") then offx = offx - speed*dt end
  if love.keyboard.isDown("right") then offx = offx + speed*dt end
  if love.keyboard.isDown("up") then offy = offy - speed*dt end
  if love.keyboard.isDown("down") then offy = offy + speed*dt end

  local x = math.floor((love.mouse.getX()+offx)/32+0.5)
  local y = math.floor((love.mouse.getY()+offy)/32+0.5)

  if love.mouse.isDown(1) then -- add wall
    found = false
    for i,v in pairs(map) do
      if v.x == x and v.y == y then
        found = true
        break
      end
    end
    if not found then
      table.insert(map,{x=x,y=y})
    end
  elseif love.keyboard.isDown("space") then --remove wall
    for i,v in pairs(map) do
      if v.x == x and v.y == y then
        table.remove(map,i)
      end
    end
  end

  if love.keyboard.isDown("s") then
    local f = io.open("map.lua","w")
    local s = "local map = {\n";
    for i,v in pairs(map) do
      s = s .. "\t{x="..v.x..",y="..v.y.."},\n"
    end
    s = s .. "}\nreturn map"
    f:write(s)
    f:close()
  end

end
