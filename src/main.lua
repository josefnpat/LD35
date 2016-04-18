if not headless then
  -- Adaptation from: https://love2d.org/forums/viewtopic.php?f=5&t=82034
  pixelfont = love.graphics.newImageFont("assets/fonts/lowfontA.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
  pixelfont:setFilter("nearest")
  love.graphics.setFont(pixelfont)

  love.graphics._print = love.graphics.print
  love.graphics.print = function(s,x,y)
    love.graphics._print(s,(x or 0)-scale,y,0,scale,scale)
  end
end

hump = {
  gamestate = require "gamestate"
}

sfx = require "sfx"

gamestates = {
  splash = require "state_splash",
  story = require "state_story",
  game = require "state_game",
  credits = require "state_credits"
}

splashclass = require "splashclass"

function love.load()
  hump.gamestate.registerEvents()
  if headless then
    hump.gamestate.switch(gamestates.game)
  else
    hump.gamestate.switch(gamestates.splash)
  end
end
