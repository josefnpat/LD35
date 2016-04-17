headless = false
scale = 10
max_health = 10
default_port = 35350
default_username = "CLONE"

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
  else
    t.window.title = "Dracul64"
    t.window.width = 64*scale
    t.window.height = 64*scale

  end

end
