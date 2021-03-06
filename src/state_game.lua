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
  demo_port = default_port

  options = {
    {
      name = function() return "CONNECT" end,-- .. (demo_ip and "remote" or "localhost") .. " server" end,
      action = function()
        client.start{ip=demo_ip,name=demo_name}
        music.menu:stop()
        music.game_intro:play()

        love.mouse.setRelativeMode(true)
      end,
    },
    {
      name = function() return server_data and
        --"Stop Server"
        "HOST [UP]" or "HOST" end,
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
      label = "name",
      name = function() return "NAME: "..(demo_name or "["..default_username.."]") end,
      action = function()
        demo_name = nil
      end,
    },
    {
      label = "ip",
      name = function() return "IP: "..(demo_ip or "[LOCALHOST]") end,
      action = function()
        demo_ip = nil
      end,
    },
    {
      name = function() return "CREDITS" end,
      action = function()
        hump.gamestate.switch(gamestates.credits)
      end,
    },
    {
      name = function() return "QUIT" end,
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
    local fh = love.graphics.getFont():getHeight()*scale
    local offset = 32
    love.graphics.print("DRACUL64",0,0)
    for i,v in pairs(options) do
      if i == current_option then
        love.graphics.setColor(255,0,0)
      else
        love.graphics.setColor(255,255,255)
      end
      love.graphics.print(v.name(),0,i*fh+offset)
    end
  end
  love.graphics.setColor(255,255,255)

  if client_data then client.draw() end
  if server_data then server.draw() end

  if fps_mode then
    love.graphics.print(love.timer.getFPS(),0,0)
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

      love.mouse.setRelativeMode(false)
    --elseif server_data then
      --server.stop()
    else
      love.event.quit()
    end
  end

end

function game:textinput(letter)
  if options[current_option].label == "name" then
    if not demo_name or demo_name:len() < 8 then
      demo_name = (demo_name or "" ) .. letter
    end
  elseif options[current_option].label == "ip" then
    demo_ip = (demo_ip or "") .. letter
  end
end

function game:mousepressed(x,y,button)
  if client_data then
    client.mousepressed(x,y,button)
  end
end

function game:mousemoved(x,y,dx,dy)
  if client_data then
    client.mousemoved(x,y,dx,dy)
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
