return function(l)

  local version = "0.1"

  -- Add version info
  l:addOp('version')
  -- Get version info to client when it requests it
  l:addProcessOnServer('version',function(self,peer,arg,storage)
    return version
  end)
  -- Process version information on client side
  l:addProcessOnClient('version',function(self,peer,arg,storage)
    if version == arg then
      return true
    else
      return "Version mismatch!\n\nClient: "..tostring(arg).."\nServer: "..tostring(version)
    end
  end)
  -- What to do while it waits for version information
  l:addDefaultOnClient('version',function(self,peer,arg,storage)
    return "Waiting for version information"
  end)

  local isValidString = function(input)
    local utf8 = require("utf8")
    local success = utf8.len(input)
    return success
  end

  -- Add a way to name users
  l:addOp('whoami')
  -- Validate the name argument
  l:addValidateOnServer('whoami',{name="string"})
  -- Store the user's name in the user data
  l:addProcessOnServer('whoami',function(self,peer,arg,storage)
    local user = self:getUser(peer)
    self:log("event","Rename: "..tostring(user.name).." => "..tostring(arg.name))
    if isValidString(arg.name) then
      user.name = arg.name
    end
  end)

  -- Add a way to send the current user's position
  l:addOp('m')
  -- Validate the x and y arguments as numbers
  l:addValidateOnServer('m',{m="number",s="number",a="number"})
  -- Store the position of the user in the user data
  l:addProcessOnServer('m',function(self,peer,arg,storage)
    local user = self:getUser(peer)
    user.x = user.x or 0
    user.y = user.y or 0
    user.move = arg.m
    user.strafe = arg.s
    user.angle = arg.a
    return {x=user.x,y=user.x}
  end)

  -- Add a way to inform all clients where all players are
  l:addOp('p')
  -- Create a table containing the name, x and y of each user
  l:addProcessOnServer('p',function(self,peer,arg,storage)
    local user = self:getUser(peer)
    local info = {}
    for i,v in pairs(self:getUsers()) do
      if v.x and v.y then
        table.insert(info,{
          name=v.name,
          m=v.move,
          s=v.strafe,
          a=v.angle,
          x=v.x,
          y=v.y,
          c=v == user and true or nil,
        })
      end
    end
    -- Return it to the requester
    return info
  end)
  -- Validate that the data is indeed a table containing users with name,x and y
  l:addValidateOnClient('p',function(self,peer,arg,storage)
    if type(arg) ~= "table" then return false,"root expecting table" end
    for i,v in pairs(arg) do
      if type(v.name) ~= "string" then return false,"v.name expecting string" end
      if type(v.x) ~= "number" then return false,"v.x expecting number" end
      if type(v.y) ~= "number" then return false,"v.y expecting number" end
    end
    return true
  end)
  -- Provide an empty table by default when a client requests the players
  l:addDefaultOnClient('p',function(self,peer,arg,storage)
    return {}
  end)

end
