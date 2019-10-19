g_info = nil
local item_uri = "$gui/frame/npcfunc/markpos.xml"
local item_style = "battle_item"
function show_window(info)
  g_info = info
end
function on_click_use_item(w)
  local item = lt_trans.item_sel
  if item == nil then
    return
  end
  local var = item.svar.var
  local function send_impl(info, excel)
    local v = sys.variant()
    v:set64(packet.key.itemdata_idx, g_info.only_id)
    v:set64(packet.key.scn_onlyid, var:get(packet.key.battlegroup_id))
    bo2.send_variant(packet.eCTS_UI_ViewBattleList, v)
  end
  send_impl(info, excel)
  w_main.visible = false
end
function on_item_sel(list)
  local item = lt_trans.item_sel
  if item == nil then
    return
  end
  on_click_use_item()
end
function item_check_hover(item)
  local vis = item.selected or item.inner_hover
  item:search("highlight_select").visible = vis
end
function on_mouse_item_trans(w, msg, pos, wheel)
  if msg == ui.mouse_inner or msg == ui.mouse_outer then
    item_check_hover(w)
  elseif msg == ui.mouse_lbutton_dbl then
    on_click_use_item()
  end
end
function on_self_enter_finish()
  g_info = nil
  if sys.check(w_main) ~= true or w_main.visible == true then
    return
  end
  w_main.visible = false
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_self_enter_finish, "ui_view_battle_list.on_self_enter_finish")
function get_server_name(server_id)
  local pServerName = bo2.gv_server_name:find(server_id)
  if sys.check(pServerName) ~= true then
    return L("")
  end
  return pServerName.value
end
function on_card_tip_show(tip)
  local owner = tip.owner
  local var = owner.svar.var
  local stk = sys.mtf_stack()
  local stk_b = sys.mtf_stack()
  local side_a = var:get(packet.key.battle_side)
  local side_b = var:get(packet.key.battlegroup_players)
  local side_a_size = side_a.size
  local side_b_size = side_b.size
  local stk = sys.mtf_stack()
  local c_size = side_a_size
  local on_make_tip = function(stk, var, c_size, head)
    for i = 0, c_size - 1 do
      local player_var = var:fetch_v(i)
      local mtf_a = {}
      mtf_a.n = player_var:get(packet.key.cha_name).v_string
      mtf_a.s = get_server_name(player_var:get(packet.key.cha_onlyid).v_int)
      if i == 0 then
        stk:raw_push(L("<a+:mid>"))
        stk:raw_push(head)
        stk:raw_push(L("<a->"))
        stk:raw_push(L("<a+:left>"))
      end
      stk:raw_push([[

 ]])
      stk:raw_push(ui_widget.merge_mtf(mtf_a, ui.get_text("npcfunc|fighter_info")))
    end
  end
  on_make_tip(stk, side_a, side_a_size, ui.get_text("battle|red_list"))
  on_make_tip(stk_b, side_b, side_b_size, ui.get_text("battle|blue_list"))
  ui_tool.ctip_show(owner, stk_b, stk)
end
function rebuild_battle_list(data)
  if g_info == nil or sys.check(g_info) ~= true then
    return
  end
  local item_excel = g_info.excel
  local use_par = item_excel.use_par
  if use_par.size <= 0 then
    return
  end
  local type = item_excel.use_par[0]
  local battle_excel = bo2.gv_battle_list:find(type)
  if battle_excel == nil then
    return
  end
  local battle_name = battle_excel.name
  lt_trans:item_clear()
  local function app_item(var)
    local app_item = lt_trans:item_append()
    app_item:load_style(item_uri, item_style)
    local app_name = app_item:search(L("name"))
    if sys.check(app_name) then
      app_name.text = battle_name
    end
    local mtf_vs = {}
    app_item.svar.var = var
    local side_a = var:get(packet.key.battle_side)
    local side_b = var:get(packet.key.battlegroup_players)
    local side_a_size = side_a.size
    local side_b_size = side_b.size
    local stk = sys.mtf_stack()
    local c_size = side_a_size
    if side_a_size < side_b_size then
      c_size = side_b_size
    end
    local player_var_a = side_a:fetch_v(0)
    local player_var_b = side_b:fetch_v(0)
    local mtf_a = {}
    mtf_a.n = player_var_a:get(packet.key.cha_name).v_string
    mtf_a.s = get_server_name(player_var_a:get(packet.key.cha_onlyid).v_int)
    local mtf_b = {}
    mtf_b.n = player_var_b:get(packet.key.cha_name).v_string
    mtf_b.s = get_server_name(player_var_b:get(packet.key.cha_onlyid).v_int)
    mtf_vs.n1 = mtf_a.n
    mtf_vs.s1 = mtf_a.s
    mtf_vs.n2 = mtf_b.n
    mtf_vs.s2 = mtf_b.s
    local text = ui_widget.merge_mtf(mtf_vs, ui.get_text("npcfunc|vs_detail"))
    local app_info = app_item:search(L("rb_item_name"))
    if sys.check(app_info) then
      app_info.text = text
    end
    app_item.tip.text = stk.text
  end
  local data_size = data.size
  for i = 0, data_size - 1 do
    local var = data:fetch_v(i)
    app_item(var)
  end
end
function r()
  local data = sys.variant()
  local s_data = sys.variant()
  local s_a = sys.variant()
  local s_name = {}
  s_name[0] = L("\214\187\206\170\196\227\181\196\208\166")
  s_name[1] = L("\190\197\206\229\182\254\198\223")
  s_name[2] = L("\210\185\192\201")
  for i, v in pairs(s_name) do
    local s_player = sys.variant()
    s_player:set(packet.key.cha_name, v)
    s_player:set(packet.key.cha_onlyid, 111)
    s_a:push_back(s_player)
  end
  local s_b = sys.variant()
  local sb_name = {}
  sb_name[0] = L("\190\163\233\240\180\204\199\233")
  sb_name[1] = L("\214\218\201\241\246\169\246\169")
  sb_name[3] = L("\176\217\192\239\183\178\206\228")
  sb_name[4] = L("\179\164\191\213\206\222\188\171\204\236")
  for i, v in pairs(sb_name) do
    local s_player = sys.variant()
    s_player:set(packet.key.cha_name, v)
    s_player:set(packet.key.cha_onlyid, 110)
    s_b:push_back(s_player)
  end
  s_data:set(packet.key.battle_side, s_a)
  s_data:set(packet.key.battlegroup_players, s_b)
  data:push_back(s_data)
  w_main.visible = true
  rebuild_battle_list(data)
end
function on_handle_view_battle_list(cmd, data)
  if g_info == nil or sys.check(g_info) ~= true then
    return
  end
  w_main.visible = true
  rebuild_battle_list(data)
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_BattleList, on_handle_view_battle_list, "ui_view_battle_list.on_handle_view_battle_list")
