board_size = 64
pixel_size = 12
headless = false
confetti = false
conway = false

function love.conf(t)

  t.version = "0.10.1"

  if headless then
    t.console = true
    t.window = false
    t.modules.graphics = false
    t.modules.window = false
  else
    t.window.title = "LoverNet Demo"
    t.window.width = pixel_size*(board_size+2)
    t.window.height = pixel_size*(board_size+2)
  end

end
