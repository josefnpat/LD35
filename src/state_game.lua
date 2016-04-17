local game = {}

function game:enter()

  love.mouse.setVisible( false )

  map = require "map"

  lovernetlib = require("lovernet")

  server = require "server"

  if headless then server.start() return end

  music = {
    menu = love.audio.newSource("assets/music/menu.ogg"),
    game_intro = love.audio.newSource("assets/music/game_intro.ogg"),
    game = love.audio.newSource("assets/music/game.ogg"),
  }

  music.menu:setLooping(true)
  music.game:setLooping(true)

  music.menu:play()

  client = require "client"

  math.randomseed(os.time())

  demo_name = nil
  demo_ip = "50.116.63.25"
  demo_port = "3535"

  options = {
    {
      label = "name",
      name = function() return "Change name: "..(demo_name or "[Peasant]") end,
      action = function()
        demo_name = nil
      end,
    },
    {
      name = function() return "Connect to " .. (demo_ip and "remote" or "localhost") .. " server" end,
      action = function()
        client.start{ip=demo_ip,name=demo_name}
        music.menu:stop()
        music.game_intro:play()
      end,
    },
    {
      label = "ip",
      name = function() return "Change demo server ip: "..(demo_ip or "[localhost]") end,
      action = function()
        demo_ip = nil
      end,
    },
    {
      name = function() return server_data and
        --"Stop Server"
        "Server Hosted" or "Host Server" end,
      action = function()
        if server_data then
          --server.stop()
        else
          server.start()
          demo_ip = nil
        end
      end,
    },
    {
      name = function() return "Quit" end,
      action = love.event.quit,
    },
  }

  current_option = 1

  --cat = love.graphics.newImage("cat.png")
  --cat:setFilter("nearest")

  --love.window.setIcon( love.image.newImageData("cat.png") )

end

function game:draw()

  if not client_data then
    love.graphics.setColor(255,255,255)

    local offset = (love.graphics.getHeight() - #options*24)/2
    love.graphics.printf("DRACUL64",0,offset-24,love.graphics.getWidth(),"center")
    for i,v in pairs(options) do
      local name = i == current_option and ">>> " .. v.name() .. " <<<" or v.name()
      love.graphics.printf(name,0,i*24+offset,love.graphics.getWidth(),"center")
    end
  end

  if client_data then client.draw() end
  if server_data then server.draw() end

  if fps_mode then
    love.graphics.printf(love.timer.getFPS(),0,0,
      love.graphics.getWidth(),"right")
  end

end

debug_mode = false
raycast_mode = true
fps_mode = false

function game:keypressed(key)

  if key == "`" then
    debug_mode = not debug_mode
  end

  if key == "1" then
    raycast_mode = not raycast_mode
    print("raycast:",raycast_mode)
  end

  if key == "f" then
    fps_mode = not fps_mode
  end

  if not client_data then

    if key == "up" then
      current_option = current_option - 1
      if current_option < 1 then
        current_option = #options
      end
    elseif key == "down" then
      current_option = current_option + 1
      if current_option > #options then
        current_option = 1
      end
    elseif key == "return" then
      options[current_option].action()
    elseif key == "backspace" then
      if options[current_option].label == "name" then
        if demo_name then
          demo_name = string.sub(demo_name,1,-2)
          if demo_name == "" then demo_name = nil end
        end
      elseif options[current_option].label == "ip" then
        if demo_ip then
          demo_ip = string.sub(demo_ip,1,-2)
          if demo_ip == "" then demo_ip = nil end
        end
      end
    end

  end

  if key == "escape" then
    if client_data then
      client.stop()
    --elseif server_data then
      --server.stop()
    else
      love.event.quit()
    end
  end

end

function game:textinput(letter)
  if options[current_option].label == "name" then
    demo_name = (demo_name or "" ) .. letter
  elseif options[current_option].label == "ip" then
    demo_ip = (demo_ip or "") .. letter
  end
end

function game:mousepressed(x,y,button)
  if client_data then
    client.mousepressed(x,y,button)
  end
end

function game:update(dt)

  if debug_mode then
    --require("lovebird").update()
  end

  if client_data then client.update(dt) end
  if server_data then server.update(dt) end
end

function love.quit()
  if client_data then client.stop() end
  if server_data then server.stop() end
end

return game
