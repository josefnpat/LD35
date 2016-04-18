headless = false
scale = 10
default_port = 35350
default_username = "CLONE"

-- server config info
max_health = 4
max_bullets = 6
respawn_bullets = 2

function love.conf(t)

  t.version = "0.10.1"

  for _,v in pairs(arg) do
    if v == "--headless" or v == "-s" then
      headless = true
    end
  end

  if headless then
    t.console = true
    t.window = false
    t.modules.graphics = false
    t.modules.window = false
    t.modules.audio = false
  else
    t.window.title = "Dracul64"
    t.window.width = 64*scale
    t.window.height = 64*scale

  end

end
