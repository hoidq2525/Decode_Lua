local g_w_main
local g_route_id = 0
local d_hotkey_input = {}
function on_test_use_skill(op_id)
  if ui_qbar.fight_route_shortcut_bar.visible == false then
    return false
  end
  if op_id >= 10 and op_id <= 15 then
    local card_slot = d_hotkey_input[op_id - 10]
    if sys.check(card_slot) then
      on_fr_card_mouse(card_slot, ui.mouse_lbutton_click, 0, 0)
      return true
    end
  end
  return false
end
function on_fr_card_mouse(card, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click or msg == ui.mouse_rbutton_click then
    fr_shortcut_use(card.excel_id)
    return
  end
end
function on_fr_card_tip_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  local info = ui.skill_find(card.excel_id)
  if info == nil then
    ui.skill_insert(card.excel_id)
    info = ui.skill_find(card.excel_id)
  end
  ui_tool.ctip_make_skill(stk, info)
  local stk_use
  ui_tool.ctip_show(card, stk, stk_use)
end
function on_fr_filcker_mouse(card, msg, pos, wheel)
  local core_flicker = card:search("core_flicker")
  if core_flicker == nil or core_flicker.visible ~= true then
    return
  end
  core_flicker.visible = false
end
function flight_route_shortcut_update()
  if sys.check(ui_qbar.fight_route_shortcut_bar) ~= true or ui_qbar.fight_route_shortcut_bar.visible == false then
    return
  end
  for i = 0, 4 do
    local key_name = sys.format(L("slot%d"), i)
    local hotkey = ui_qbar.fight_route_shortcut_bar:search(key_name)
    if sys.check(hotkey) then
      local hotkey_text = ui_setting.ui_input.get_op_simple_text(3000 + i)
      local lb_hotkey = hotkey:search("hotkey")
      lb_hotkey.text = hotkey_text
    end
  end
end
function on_init_skill_shortcut(v)
  local pExcel = bo2.gv_flight_route:find(v)
  if pExcel == nil then
    return
  end
  if ui_qbar.fight_route_shortcut_bar.visible ~= false and pExcel.id == g_route_id then
    return
  end
  local size_skill = pExcel.use_skill.size
  if size_skill <= 0 then
    return
  end
  g_route_id = pExcel.id
  g_w_main = ui_qbar.fight_route_shortcut_bar
  g_w_main.visible = true
  local v1, v2
  d_hotkey_input = {}
  for i = 0, size_skill - 1 do
    local skill_id = pExcel.use_skill[i]
    local cname = sys.format("slot%d", i)
    local card_panel = g_w_main:search(cname)
    local card = card_panel:search("card")
    card.excel_id = skill_id
    local skill_icon = ui.get_skill_icon(card.excel_id)
    local icon_uri, card_icon
    if skill_icon ~= nil and skill_icon.uri ~= nil then
      icon_uri = skill_icon.uri
      card_icon = sys.format(L("$icon/skill/%s.png"), skill_icon.excel.icon)
    else
      icon_uri = sys.format(L("$icon/skill/cmn/001.png"))
      card_icon = icon_uri
    end
    card.icon_name = card_icon
    local image = card_panel:search("image_filcker")
    image.image = icon_uri
    d_hotkey_input[i] = card
  end
  flight_route_shortcut_update()
end
function fr_shortcut_use(excel_id)
  bo2.use_skill(excel_id)
end
function runf_test(Routeid)
  local v = sys.variant()
  v:set(packet.key.ui_window_type, packet.key.ui_flight_route_name)
  v:set(packet.key.ui_flight_skill_detail, Routeid.v_int)
  handle_open_window(0, v)
end
function handle_open_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_int
  if win_type ~= packet.key.ui_flight_route_name then
    return
  end
  local _v = data:get(packet.key.ui_flight_skill_detail).v_int
  if _v ~= 0 then
    on_init_skill_shortcut(_v)
  end
end
function runf_close()
  fight_route_shortcut_bar.visible = false
  g_route_id = 0
  d_hotkey_input = {}
end
function handle_close_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_int
  if win_type ~= packet.key.ui_flight_route_name then
    return
  end
  local excel_id = data:get(packet.key.ui_flight_route_id).v_int
  runf_close()
end
local reg = ui_packet.game_recv_signal_insert
reg(packet.eSTC_UI_OpenWindow, handle_open_window, "ui_qbar_flight.packet_handle")
reg(packet.eSTC_UI_CloseWindow, handle_close_window, "ui_qbar_flight.packet_handle_close")
