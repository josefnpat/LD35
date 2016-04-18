local story = {}

local s = string.upper("\n\n\nDRACUL64\n\nOur hero is an unprofessional vampire hunter, and he hears of a shapeshifting vampire in a castle. The only way to prevent the vampire from forming as his friends is to go alone. Unfortunately our hero had fallen into a cloning machine a few weeks back and his clones refuse to leave him alone and follow him into the castle.\n\nLuckily the vampire doesn't have a gun. Our hero(s) treads lightly...")

local width, wrappedtext = love.graphics.getFont():getWrap( s, 64)
local sheight = love.graphics.getFont():getHeight()*#wrappedtext*scale

local t = -1

local offset = 0
local fast = false

function story:draw()
  offset = math.floor(math.max(0,t*64)/10)*10
  love.graphics.printf(s,0,-offset,64,"center",0,scale,scale)
end

function story:update(dt)
  if fast then
    t = t + dt*10
  else
    t = t + dt
  end
  if offset > sheight then
    hump.gamestate.switch(gamestates.game)
  end
end

function story:keypressed(key)
  if key == "escape" then
    t = math.huge
  end
  fast = true
end

function story:mousepressed()
  fast = true
end

return story
