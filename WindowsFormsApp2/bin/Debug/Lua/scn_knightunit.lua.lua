local reg = ui_packet.game_recv_signal_insert
local sig = "ui_scn_knightunit.packet_handler"
g_match_id = 0
g_scn_onlyid = 0
g_fight_list = {}
g_knight_members = {}
g_item_back_color = {}
g_spectator_count = 0
g_is_in_scn = false
function on_status_init()
  g_fight_list = {
    [0] = gx_fight_lista,
    [1] = gx_fight_listb
  }
  g_item_back_color = {
    [0] = ui.make_color("fff1a502"),
    [1] = ui.make_color("ff038abb")
  }
end
function on_toggle_click_close(btn)
  gx_status_window.visible = false
end
function auto_select()
  if g_knight_members[bo2.player.name] ~= nil then
    return
  end
  if g_fight_list[0].item_sel ~= nil then
    return
  elseif g_fight_list[1].item_sel ~= nil then
    return
  end
  for i = 0, 1 do
    for j = 0, g_fight_list[i].item_count - 1 do
      local panel = g_fight_list[i]:item_get(j)
      if panel.svar ~= 0 then
        panel.selected = true
        panel:search("hilight").visible = true
        bo2.ChgCamera(panel.svar)
        bo2.player:SetTarget(panel.svar)
        return
      end
    end
  end
end
function on_career_tip_make(tip)
  local panel = tip.owner.parent
  local career_panel = panel:search("job")
  local pro_list = bo2.gv_profession_list:find(career_panel.svar)
  text = sys.format("%s", pro_list.name)
  ui_widget.tip_make_view(tip.view, text)
end
function get_career_idx(val)
  local pro = bo2.gv_profession_list:find(val)
  if pro == nil then
    return 0
  end
  return pro.career - 1
end
function RenderPlayerItem(item, var, type)
  local name = var:get(packet.key.cha_name).v_string
  item:search("player_name").text = name
  local level = var:get(packet.key.cha_level).v_int
  item:search("level").text = sys.format("lv%d", level)
  if type == 0 then
    local portrait = var:get(packet.key.cha_portrait).v_int
    local por_list = bo2.gv_portrait:find(portrait)
    item:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
  elseif type == 1 then
    local portrait = var:get(packet.key.cha_portrait).v_string
    item:search("portrait").image = sys.format("$icon/portrait/%s", portrait)
    item:search("portrait").svar = portrait
  end
  local career = var:get(packet.key.player_profession).v_int
  local handle = var:get(packet.key.scnobj_handle).v_int
  item.svar = handle
  local career_panel = item:search("job")
  local career_idx = get_career_idx(career)
  career_panel.irect = ui.rect(career_idx * 21, 0, (career_idx + 1) * 21, 32)
  career_panel.svar = career
  local cur_hp = var:get(packet.key.cha_cur_hp).v_int
  local max_hp = var:get(packet.key.cha_max_hp).v_int
  item:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
  item:search("cur_hp").parent.dx = 170 * (cur_hp / max_hp)
  g_knight_members[name] = item
end
function add_arena_member(var, type)
  local side = var:get(packet.key.arena_side).v_int
  local list = g_fight_list[side]
  if not list then
    return
  end
  local item = list:item_append()
  item:load_style("$frame/scn_knightunit/scn_knightunit.xml", "player_item_3")
  item:search("player_name").color = g_item_back_color[side]
  RenderPlayerItem(item, var, type)
end
function handleShowFightInfo(cmd, data)
  gx_fight_lista:item_clear()
  gx_fight_listb:item_clear()
  g_knight_members = {}
  g_match_id = data:get(packet.key.scnmatch_id)
  g_scn_onlyid = data:get(packet.key.scn_onlyid)
  g_is_in_scn = data:has(packet.key.arena_in_scn)
  if g_is_in_scn then
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, on_player_enter, "ui_scn_knightunit:on_player_enter")
  end
  local players = data:get(packet.key.arena_players)
  local player_var = players:get(0)
  add_arena_member(player_var, 0)
  for i = 1, players.size - 1 do
    local npc_var = players:get(i)
    add_arena_member(npc_var, 1)
  end
  local player_handle = player_var:get(packet.key.scnobj_handle).v_int
  g_spectator_count = data:get(packet.key.player_count).v_int
  gx_text_seecount.text = sys.format(ui.get_text("scn_matchunit|see_count"), g_spectator_count)
  gx_btn_goin.visible = not g_is_in_scn
  gx_btn_goout.visible = g_is_in_scn
  gx_btn_applaud.visible = g_is_in_scn
  gx_btn_catcall.visible = g_is_in_scn
  gx_btn_mute.visible = g_is_in_scn
  gx_btn_mute_disable.visible = false
  if g_is_in_scn and g_knight_members[bo2.player.name] == nil then
    bo2.player:SetShow(bo2.eShowType_MatchSpectator, false)
    bo2.SetMatchSpectator(true)
    ui_knight_cmn.set_visible(true)
  end
  gx_status_type.text = ui.get_text("scn_matchunit|practice_title")
  gx_status_window.visible = true
end
function ClickGoinMatchScn()
  local var = sys.variant()
  var:set(packet.key.scnmatch_id, g_match_id)
  var:set(packet.key.scn_onlyid, g_scn_onlyid)
  bo2.send_variant(packet.eCTS_UI_GoinKnightScn, var)
  gx_status_window.visible = false
end
function on_item_mouse(panel, msg, pos, wheel)
  if g_knight_members[bo2.player.name] ~= nil then
    return
  end
  if not g_is_in_scn then
    return
  end
  if msg == ui.mouse_lbutton_click then
  end
end
function on_fight_chghp(obj)
  local max_hp = obj:get_atb(bo2.eAtb_HPMax)
  local cur_hp = obj:get_atb(bo2.eAtb_HP)
  local item = g_knight_members[obj.name]
  item:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
  item:search("cur_hp").parent.dx = 170 * (cur_hp / max_hp)
end
function on_player_enter(obj, msg)
  if g_knight_members[obj.name] ~= nil and g_is_in_scn then
    on_fight_chghp(obj)
    g_knight_members[obj.name].svar = obj.sel_handle
    auto_select()
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, on_fight_chghp, "ui_scn_knightunit:on_fight_chghp")
  end
  bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, on_player_leave, "ui_scn_knightunit:on_player_leave")
end
function on_quite(btn)
end
function on_link(btn)
  local text = gx_status_type.text
  local player_name1 = gx_fight_lista:item_get(0):search("player_name").text
  local player_name2 = gx_fight_listb:item_get(0):search("player_name").text
  text = text .. ":" .. player_name1 .. " VS " .. player_name2
  ui_chat.insert_matchscn(g_scn_onlyid, text)
end
function ClickApplaud(btn)
  local var = sys.variant()
  var:set(packet.key.cmn_type, bo2.eSpectatorAction_Applaud)
  bo2.send_variant(packet.eCTS_MatchSpectator_Action, var)
end
function ClickCatcall(btn)
  local var = sys.variant()
  var:set(packet.key.cmn_type, bo2.eSpectatorAction_Catcall)
  bo2.send_variant(packet.eCTS_MatchSpectator_Action, var)
end
function ClickMute(btn)
  if btn == gx_btn_mute then
    btn.visible = false
    gx_btn_mute_disable.visible = true
  else
    btn.visible = false
    gx_btn_mute.visible = true
  end
  local var = sys.variant()
  var:set(packet.key.cmn_type, bo2.eSpectatorAction_Mute)
  bo2.send_variant(packet.eCTS_MatchSpectator_SetAction, var)
end
function ClickSee(btn)
  ui_match.viewlist.OpenViewerPage(packet.eCTS_MatchScn_ViewerListReq, g_scn_onlyid)
end
function on_timer(timer)
end
function handleUpdateSpectators(cmn, var)
  local count = var:get(packet.key.player_count).v_int
  g_spectator_count = g_spectator_count + count
  gx_text_seecount.text = sys.format(ui.get_text("scn_matchunit|see_count"), g_spectator_count)
end
function handleCloseWin()
  g_is_in_scn = false
  gx_timer.suspended = true
  ui_knight_cmn.set_visible(false)
  bo2.SetMatchSpectator(false)
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, "ui_scn_knightunit:on_player_enter")
end
function on_player_leave()
  handleCloseWin()
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, "ui_scn_knightunit:on_player_leave")
end
reg(packet.eSTC_UI_KnightScnClose, handleCloseWin, sig)
reg(packet.eSTC_KnightScn_SpectatorsCount, handleUpdateSpectators, sig)
reg(packet.eSTC_UI_ShowFightScnInfo, handleShowFightInfo, sig)
