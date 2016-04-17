local sprites = {}

sprites.stand = {}
for i = 1,8 do
  sprites.stand[i] = love.graphics.newQuad((i-1)*64,0,64,64,1024,1024)
end

sprites.walk = {}
for i = 1,4 do
  sprites.walk[i] = {}
  for j = 1,8 do
    sprites.walk[i][j] = love.graphics.newQuad((j-1)*64,i*64,64,64,1024,1024)
  end
end

sprites.death = {}
for i = 1,5 do
  sprites.death[i] = love.graphics.newQuad( (i-1)*64,64*5,64,64,1024,1024)
end

sprites.shoot = {}
for i = 1,3 do
  sprites.shoot[i] = {}
  for j = 1,3 do
    sprites.shoot[i][j] = love.graphics.newQuad((j-1)*64,(i+5)*64,64,64,1024,1024)
  end
end

return sprites
