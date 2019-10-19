commands = {}
LINE_CONNECT_ADDRESS = "g"
LINE_CONNECT_ADDRESS_OTHER = "o"
function getcommandlines()
  local getvirgule = function(s)
    if s == nil then
      return false
    end
    local n = string.sub(s, 1, 1)
    if n == "-" then
      return true
    else
      return false
    end
  end
  local v = bo2.getcommandline()
  for i = 1, v.size - 1 do
    local s = tostring(v:get(i))
    if getvirgule(s) then
      local cmd = string.sub(s, 2)
      if getvirgule(tostring(v:get(i + 1))) then
        commands[cmd] = nil
      else
        commands[cmd] = tostring(v:get(i + 1))
      end
    end
  end
end
function getcommand(s)
  if s == nil then
    return nil
  end
  for k, v in pairs(commands) do
    if k == s then
      return v
    end
  end
  return nil
end
local runtime_cfg_server_address = 1
function get_cfg_ip()
  return bo2.get_runtime_cfg():get(runtime_cfg_server_address).v_string
end
