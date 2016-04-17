hump = {
  gamestate = require "gamestate"
}

gamestates = {
  splash = require "state_splash",
  game = require "state_game",
}

splashclass = require "splashclass"

function love.load()
  hump.gamestate.registerEvents()
  hump.gamestate.switch(gamestates.splash)
end
