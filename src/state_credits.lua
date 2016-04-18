local credits = {}

local s = string.upper("\n\n\nThis game was made for Ludum Dare 35 and Low Rez Jam 2016.\n\nGamedev & Voiceovers: @josefnpat (Missing Sentinel Software)\n\nMusic & SFX: @mistrsinestr (Eternal Night Productions\n\nArtwork: @ByteDesigning")

local width, wrappedtext = love.graphics.getFont():getWrap( s, 64)
local sheight = love.graphics.getFont():getHeight()*#wrappedtext*scale

local t = -1

local offset = 0
local fast = false

function credits:draw()
  offset = math.floor(math.max(0,t*64)/10)*10
  love.graphics.printf(s,0,-offset,64,"center",0,scale,scale)
end

function credits:update(dt)
  if fast then
    t = t + dt*10
  else
    t = t + dt
  end
  if offset > sheight then
    hump.gamestate.switch(gamestates.game)
  end
end

function credits:keypressed(key)
  if key == "escape" then
    t = math.huge
  end
  fast = true
end

function credits:mousepressed()
  fast = true
end

return credits
