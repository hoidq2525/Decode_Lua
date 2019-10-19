local reg = ui_packet.game_recv_signal_insert
local sig = "ui_battle_common.packet_handler"
local g_fighter_list = {}
local g_cur_rank = 0
local g_open = 0
local g_sel_panel
local d_right_margin = ui.rect(10, 0, 2, 0)
function on_make_tip(tip)
  local panel = tip.owner
  local l_o_r = panel.parent
  if l_o_r.margin == d_right_margin then
    tip.popup = L("x1")
  end
  if tostring(panel:search("name").text) ~= "" then
    tip.text = panel:search("name").text
  else
    tip.text = ui.get_text("match|wait")
  end
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_click_win_btn(btn)
  if w_win.visible == false and not ui_scn_matchunit.g_is_in_scn then
    local var = sys.variant()
    bo2.send_variant(packet.eCTS_TheBestFighter_GetList, var)
  else
    if ui_scn_matchunit.g_is_in_scn then
      ui_chat.show_ui_text_id(73107)
    end
    w_win.visible = false
  end
end
function on_name_click(panel, msg, pos, wheel)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  if tostring(panel.name) == "name0" then
    on_item_click(panel.parent:search("sel0"), msg, pos, wheel)
  end
  if tostring(panel.name) == "name1" then
    on_item_click(panel.parent:search("sel1"), msg, pos, wheel)
  end
end
function on_item_click(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_click then
    if panel.svar.idx == nil then
      return
    end
    if g_fighter_list[panel.svar.idx].rank ~= g_cur_rank then
      return
    end
    if panel.svar.rank ~= g_cur_rank then
      return
    end
    if g_open == 0 then
      return
    end
    if g_sel_panel ~= nil then
      g_sel_panel:search("sel").visible = false
    end
    panel:search("sel").visible = true
    g_sel_panel = panel
  end
end
function on_goto_click(btn)
  if g_sel_panel == nil then
    return
  end
  if g_open == 0 then
    return
  end
  local idx = g_sel_panel.svar.idx
  local player = g_fighter_list[idx]
  if player == nil then
    return
  end
  local var = sys.variant()
  if btn.svar.watch == true then
    var:set(packet.key.cmn_id, player.id)
    bo2.send_variant(packet.eCTS_TheBestFighter_GotoScn, var)
  else
    bo2.send_variant(packet.eCTS_TheBestFighter_FighterIn, var)
  end
end
function ask_invite(click, data)
  if click == "yes" then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_TheBestFighter_FighterIn, v)
  else
  end
end
function add_fighter_2(player)
  local idx = math.ceil(player.idx / 16)
  local panel_name = sys.format("fighter_2_%d", idx)
  local panel = w_win:search(panel_name)
  panel:search("name").text = player.name
  panel:search("portrait").visible = true
  panel:search("style_name").visible = true
  panel:search("sel_style").svar.idx = player.idx
  panel:search("sel_style").svar.rank = 2
  local por_list = bo2.gv_portrait:find(player.portrait)
  if por_list ~= nil then
    panel:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
  end
  if player.rank == 2 and player.mark ~= 0 then
    panel:search("lose_fix").visible = true
  end
end
function add_fighter_4(player)
  local idx = math.ceil(player.idx / 8)
  local panel_name = sys.format("fighter_4_%d", idx)
  local panel = w_win:search(panel_name)
  panel:search("name").text = player.name
  panel:search("portrait").visible = true
  panel:search("style_name").visible = true
  panel:search("sel_style").svar.idx = player.idx
  panel:search("sel_style").svar.rank = 4
  local por_list = bo2.gv_portrait:find(player.portrait)
  if por_list ~= nil then
    panel:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
  end
  if player.rank == 4 then
    if player.mark ~= 0 then
      panel:search("lose_fix").visible = true
    end
  else
    add_fighter_2(player)
  end
end
function add_fighter_8(player)
  local idx = math.ceil(player.idx / 4)
  local panel_name = sys.format("fighter_8_%d", idx)
  local panel = w_win:search(panel_name)
  panel:search("name").text = player.name
  panel:search("portrait").visible = true
  panel:search("style_name").visible = true
  panel:search("sel_style").svar.idx = player.idx
  panel:search("sel_style").svar.rank = 8
  local por_list = bo2.gv_portrait:find(player.portrait)
  if por_list ~= nil then
    panel:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
  end
  if player.rank == 8 then
    if player.mark ~= 0 then
      panel:search("lose_fix").visible = true
    end
  else
    add_fighter_4(player)
  end
end
function add_fighter_16(player)
  local idx = math.ceil(player.idx / 2)
  local temp_idx = 0
  if idx % 2 == 0 then
    idx = idx / 2
    temp_idx = 1
  else
    idx = (idx + 1) / 2
  end
  local panel_name = sys.format("fighter_16_%d", idx)
  local panel = w_win:search(panel_name)
  panel:search("name" .. temp_idx):search("name").text = player.name
  panel:search("style_who" .. temp_idx).visible = false
  panel:search("sel" .. temp_idx).svar.idx = player.idx
  panel:search("sel" .. temp_idx).svar.rank = 16
  if player.rank == 16 then
    if player.mark ~= 0 then
      panel:search("lose" .. temp_idx).visible = true
    end
  else
    add_fighter_8(player)
  end
end
function add_fighter_32(player)
  local idx = player.idx
  local temp_idx = 0
  if idx % 2 == 0 then
    idx = idx / 2
    temp_idx = 1
  else
    idx = (idx + 1) / 2
  end
  local panel_name = sys.format("fighter_32_%d", idx)
  local panel = w_win:search(panel_name)
  panel:search("name" .. temp_idx):search("name").text = player.name
  panel:search("sel" .. temp_idx).svar.idx = player.idx
  panel:search("sel" .. temp_idx).svar.rank = 32
  if player.rank == 32 then
    if player.mark ~= 0 then
      panel:search("lose" .. temp_idx).visible = true
    end
  else
    add_fighter_16(player)
  end
end
function clearall()
  for idx = 1, 16 do
    local panel = w_win:search(sys.format("fighter_32_%d", idx))
    panel:search("name0"):search("name").text = ""
    panel:search("sel0").svar = {}
    panel:search("lose0").visible = false
    panel:search("name1"):search("name").text = ""
    panel:search("sel1").svar = {}
    panel:search("lose1").visible = false
  end
  for idx = 1, 8 do
    local panel = w_win:search(sys.format("fighter_16_%d", idx))
    panel:search("name0"):search("name").text = ""
    panel:search("style_who0").visible = true
    panel:search("sel0").svar = {}
    panel:search("lose0").visible = false
    panel:search("name1"):search("name").text = ""
    panel:search("style_who1").visible = true
    panel:search("sel1").svar = {}
    panel:search("lose1").visible = false
  end
  for idx = 1, 8 do
    local panel = w_win:search(sys.format("fighter_8_%d", idx))
    panel:search("name").text = ""
    panel:search("portrait").visible = false
    panel:search("style_name").visible = false
    panel:search("sel_style").svar = {}
    panel:search("lose_fix").visible = false
  end
  for idx = 1, 4 do
    local panel = w_win:search(sys.format("fighter_4_%d", idx))
    panel:search("name").text = ""
    panel:search("portrait").visible = false
    panel:search("style_name").visible = false
    panel:search("sel_style").svar = {}
    panel:search("lose_fix").visible = false
  end
  for idx = 1, 2 do
    local panel = w_win:search(sys.format("fighter_2_%d", idx))
    panel:search("name").text = ""
    panel:search("portrait").visible = false
    panel:search("style_name").visible = false
    panel:search("sel_style").svar = {}
    panel:search("lose_fix").visible = false
  end
end
local do_load_core = function()
  local core_svar = w_main_core.svar
  if core_svar.core_init ~= nil then
    return
  end
  core_svar.core_init = true
  w_main_core:load_style("$frame/thebestfighter/thebestfighter.xml", "content")
end
function on_main_visible(wnd, vis)
  if vis then
    do_load_core()
  end
end
function handleShowFighterInfo(cmd, data)
  do_load_core()
  g_cur_rank = 0
  g_open = data:get(packet.key.cmn_state).v_int
  w_goin_btn.text = ui.get_text("match|apply_enter")
  w_goin_btn.svar.watch = true
  if sys.check(g_sel_panel) == true then
    g_sel_panel:search("sel").visible = false
    g_sel_panel = nil
  end
  local player_idx
  local players = data:get(packet.key.arena_players)
  if g_open == 0 then
    w_goin_btn.visible = false
  else
    g_cur_rank = data:get(packet.key.cmn_index).v_int
    w_goin_btn.visible = true
  end
  clearall()
  for i = 0, players.size - 1 do
    local player = players:get(i)
    local idx = player:get(packet.key.cmn_index).v_int
    g_fighter_list[idx] = {
      idx = idx,
      id = player:get(packet.key.cmn_id),
      name = player:get(packet.key.cha_name).v_string,
      rank = player:get(packet.key.cmn_rank).v_int,
      mark = player:get(packet.key.cmn_state).v_int,
      level = player:get(packet.key.cha_level).v_int,
      portrait = player:get(packet.key.cha_portrait).v_int,
      profession = player:get(packet.key.player_profession).v_int
    }
    add_fighter_32(g_fighter_list[idx])
    if bo2.player.name == g_fighter_list[idx].name then
      player_idx = idx
    end
  end
  if player_idx ~= nil and g_open ~= 0 and g_fighter_list[player_idx].rank == g_cur_rank and g_fighter_list[player_idx].mark == 0 then
    w_goin_btn.text = ui.get_text("match|player_enter")
    w_goin_btn.svar.watch = false
  end
  w_win.visible = true
end
reg(packet.eSTC_UI_TheBestFighter_List, handleShowFighterInfo, sig)
