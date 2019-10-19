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
function fr_shortcut_use(excel_id)
  bo2.use_skill(excel_id)
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
function on_init_temp_skill_shotcut()
  local pExcel = {
    115020,
    115021,
    115022,
    115024
  }
  local parent = ui.create_control(ui.find_control("$phase:main"), "panel")
  parent:load_style("$frame/qbar/fight_route_shortcut.xml", "fight_route_shortcut_bar")
  for i = 0, #pExcel - 1 do
    local skill_id = pExcel[i + 1]
    local cname = sys.format("slot%d", i)
    local card_panel = parent:search(cname)
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
    d_hotkey_input[i] = card
  end
  parent.visible = true
  g_w_main = parent
  if sys.check(parent) ~= true or parent.visible == false then
    return
  end
  for i = 0, 4 do
    local key_name = sys.format(L("slot%d"), i)
    local hotkey = parent:search(key_name)
    if sys.check(hotkey) then
      local hotkey_text = ui_setting.ui_input.get_op_simple_text(3000 + i)
      local lb_hotkey = hotkey:search("hotkey")
      lb_hotkey.text = hotkey_text
    end
  end
end
function handle_open_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_string
  if win_type ~= L("banghui_hubiao") then
    return
  end
  on_init_temp_skill_shotcut()
end
function runf_close()
  g_w_main.visible = false
  g_route_id = 0
  d_hotkey_input = {}
end
function handle_close_window(cmd, data)
  local win_type = data:get(packet.key.ui_window_type).v_string
  if win_type ~= L("banghui_hubiao") then
    return
  end
  runf_close()
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_tempskill_hubiao.packet_handle"
reg(packet.eSTC_UI_OpenWindow, handle_open_window, sig)
reg(packet.eSTC_UI_CloseWindow, handle_close_window, sig)
