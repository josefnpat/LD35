sprites = require "sprites"()

sheet = love.graphics.newImage("sprites.png")
sheet:setFilter("nearest")

weapons = love.graphics.newImage("weapons.png")
weapons:setFilter("nearest")

t = 0

walkframes = 4

function love.draw()
  local dirindex = math.floor(t)%8+1
  local animindex = math.floor(t)%walkframes+1
  love.graphics.rectangle("line",0,0,scale*64,scale*64)
  love.graphics.draw(sheet,sprites.stand[dirindex],0,0,0,scale,scale)

  local weaponindex = math.floor(t)%5+1
  for i,v in pairs(sprites.weapon_quads) do
    love.graphics.rectangle("line",64*scale*i,0,64*scale,32*scale)
    love.graphics.draw(weapons,v[weaponindex],64*scale*i,0,0,scale,scale)
  end

  for i = 1,8 do
    local x = (i-1)*scale*64
    local y = 64*scale
    love.graphics.rectangle("line",x,y,64*scale,64*scale)
    love.graphics.draw(sheet,sprites.walk[i][animindex],x,y,
      0,scale,scale)
  end

  local deathindex = math.floor(t)%2+1
  love.graphics.rectangle("line",0,64*2*scale,64*scale,64*scale)
  love.graphics.draw(sheet,sprites.death[deathindex],
    0,64*2*scale,0,scale,scale)

  local shootindex = math.floor(t)%3+1
  for i = 1,3 do
    local x = (i-1)*64*scale
    local y = 3*64*scale
    love.graphics.rectangle("line",x,y,64*scale,64*scale)
    love.graphics.draw(sheet,sprites.shoot[i][shootindex],x,y,
      0,scale,scale)
  end
end

function love.update(dt)
  t = t + dt*4
end
