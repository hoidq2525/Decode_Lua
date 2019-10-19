local g_def = {}
g_def.g = {scale = 10000}
g_def.s = {scale = 100}
g_def.c = {scale = 1}
local MAX_MONEY = 2147483647
function set_money(ctrl, cnt)
  ctrl:search("money_lb").money = cnt
  local function set_edit(name, left_money)
    local scale = g_def[name].scale
    local num = left_money / scale
    num = math.floor(num)
    ctrl:search(name).text = num
    return left_money - num * scale
  end
  cnt = set_edit("g", cnt)
  cnt = set_edit("s", cnt)
  set_edit("c", cnt)
end
function set_enable(ctrl, enabled)
  ctrl:search("money_lb").visible = not enabled
  ctrl:search("money_tb").visible = enabled
  ctrl:search("money_lb").money = get_money(ctrl)
end
function get_money(ctrl)
  local function get_input(name)
    local num = ctrl:search(name).text.v_int
    local scale = g_def[name].scale
    return num * scale
  end
  local rst = get_input("g") + get_input("s") + get_input("c")
  if rst > MAX_MONEY then
    return 0
  else
    return rst
  end
end
