local uri = "$frame/state/state.xml"
local card_sty_normal = "state_unit"
local card_sty_mini = "state_unit_mini"
local card_sty_mini2 = "state_unit_mini2"
local card_sty_mini_left = "state_unit_mini_left"
local card_sty_mini_right = "state_unit_mini_right"
function init_state_group(panel, uri, sty)
  if panel == nil then
    return
  end
  for i = 1, 10 do
    local item = ui.create_control(panel, "panel")
    item:load_style(uri, sty)
    local card = item:search("card")
    if card then
      card.index = i
      card.name = "card" .. i
    end
  end
end
function set_mini_handle(panel, handle)
  set_handle(panel:search("active"), handle, 1)
  set_handle(panel:search("positive"), handle, 2)
  set_handle(panel:search("system"), handle, 3, 1)
end
function set_handle(panel, handle, type, filter)
  for i = 1, 10 do
    local name = "card" .. i
    local card = panel:search(name)
    if card then
      card.handle = handle
      card.type = type
      if filter ~= nil then
        card.filter = true
      end
    end
  end
end
function set_state(obj)
  local handle = obj.sel_handle
  set_handle(w_state_active, handle, 1)
  set_handle(w_state_positive, handle, 2)
  set_handle(w_state_system, handle, 3)
end
function cal_time_t(days, hours, minutes, seconds)
  local text = L("")
  if days > 0 then
    text = sys.format("%d%s%d%s%d%s%d%s", days, ui.get_text("state|day"), hours, ui.get_text("state|hour"), minutes, ui.get_text("state|minute"), seconds, ui.get_text("state|second"))
  elseif hours > 0 then
    text = sys.format("%d%s%d%s%d%s", hours, ui.get_text("state|hour"), minutes, ui.get_text("state|minute"), seconds, ui.get_text("state|second"))
  elseif minutes > 0 then
    text = sys.format("%d%s%d%s", minutes, ui.get_text("state|minute"), seconds, ui.get_text("state|second"))
  elseif seconds > 0 then
    text = sys.format("%d%s", seconds, ui.get_text("state|second"))
  end
  return text
end
function cal_time(time)
  time = math.floor(time / 1000)
  local days = math.floor(time / 86400)
  time = time % 86400
  local hours = math.floor(time / 3600)
  time = time % 3600
  local minutes = math.floor(time / 60)
  time = time - minutes * 60
  local seconds = math.floor(time)
  return cal_time_t(days, hours, minutes, seconds)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local info = ui.find_state_bytype(card.handle, card.index, card.type)
  if info == nil then
    return
  end
  local excel = info.excel
  if excel == nil then
    ui.log("on_card_tip_show excel nil")
    return
  end
  local stk = sys.mtf_stack()
  local days, hours, minutes, seconds = info:get_remain_time()
  ui_tool.ctip_make_state(stk, info, cal_time_t(days, hours, minutes, seconds))
  ui_tool.ctip_show(card, stk)
end
function on_state_mouse(card, msg, pos, data)
  if card.type ~= 1 then
    return
  end
  local info = ui.find_state_bytype(card.handle, card.index, card.type)
  if info == nil then
    return
  end
  if msg == ui.mouse_rbutton_click then
    state_cannel(info.only_id, info.excel.id)
  end
end
function on_card_init(panel)
  init_state_group(panel, uri, card_sty_normal)
end
function on_card_init_mini(panel)
  init_state_group(panel:search("active"), uri, card_sty_mini)
  init_state_group(panel:search("positive"), uri, card_sty_mini)
  init_state_group(panel:search("system"), uri, card_sty_mini)
end
function on_card_init_mini2(panel)
  init_state_group(panel:search("active"), uri, card_sty_mini2)
  init_state_group(panel:search("positive"), uri, card_sty_mini2)
end
function init_state_mini(panel, uri, sty)
  if panel == nil then
    return
  end
  for i = 1, 10 do
    local item = ui.create_control(panel, "panel")
    item:load_style(uri, sty)
    local card = item:search("card")
    if card then
      card.index = i
      card.name = "card" .. i
    end
  end
end
function on_card_init_mini_left(panel)
  init_state_mini(panel:search("active"), uri, card_sty_mini_left)
  init_state_mini(panel:search("positive"), uri, card_sty_mini_left)
  init_state_mini(panel:search("system"), uri, card_sty_mini_left)
end
function on_card_init_mini_right(panel)
  init_state_mini(panel:search("active"), uri, card_sty_mini_right)
  init_state_mini(panel:search("positive"), uri, card_sty_mini_right)
  init_state_mini(panel:search("system"), uri, card_sty_mini_right)
end
function on_init()
  ui.log("state in")
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, set_state, "ui_state:set_state")
