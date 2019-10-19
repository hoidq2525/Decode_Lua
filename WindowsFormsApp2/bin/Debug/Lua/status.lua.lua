g_arena_mode = 0
g_arena_id = 0
g_arena_mode_data = 0
g_fight_list = {}
g_item_back_color = {}
g_members_item = {}
g_members_var = {}
g_inArenaScn = false
g_cur_time = 0
function on_status_init()
  g_fight_list = {
    [0] = gx_fight_lista,
    [1] = gx_fight_listb
  }
  g_item_back_color = {
    [0] = ui.make_color("fff1a502"),
    [1] = ui.make_color("ff038abb")
  }
  g_watchOn = false
  gx_innermng_pn.visible = false
  g_members_var = {}
  g_members_item = {}
  gx_fight_lista:item_clear()
  gx_fight_listb:item_clear()
end
function GetMatchType(data)
  local match_type = data:get(packet.key.arena_mode).v_int
  local match_type_count = data:get(packet.key.arena_mode_data).v_int
  local text = ""
  if match_type_count == 1 then
    text = ui.get_text("match|mode_1v1")
  elseif match_type_count == 3 then
    text = ui.get_text("match|mode_3v3")
  elseif match_type_count == 5 then
    text = ui.get_text("match|mode_dooaltar")
  end
  if match_type == bo2.eMatchType_ArenaSingle then
    text = ui.get_text("match|duel_fight")
  elseif match_type == bo2.eMatchType_ArenaSinglePractice then
    text = ui.get_text("match|duel_fight_0")
  end
  return text
end
function GetSimpleMatchType(match_type, match_type_count)
  local idx = 0
  if match_type_count == 1 then
    idx = 1
  elseif match_type_count == 3 then
    idx = 2
  elseif match_type_count == 5 then
    idx = 4
  end
  if match_type == bo2.eMatchType_ArenaSingle then
    idx = 1
  elseif match_type == 3 then
    idx = idx + 1
  end
  return ui.get_text("match|mode_search_" .. idx)
end
function set_player_lost(data)
  local side = data:get(packet.key.arena_side).v_int
  local turn_idx = data:get(packet.key.cmn_index).v_int
  local item = g_fight_list[side]:item_get(turn_idx)
  item:search("death_color").visible = true
  on_pk_end(side, item)
end
function auto_select()
  if ui_match_cmn.is_match_enable() == false then
    return
  end
  for i = 0, 1 do
    for j = 0, g_fight_list[i].item_count - 1 do
      local panel = g_fight_list[i]:item_get(j)
      if panel.svar ~= 0 and panel:search("fight_flag").visible == true then
        bo2.ChgCamera(panel.svar)
        bo2.player:SetTarget(panel.svar)
        return
      end
    end
  end
end
function open_status_window(var)
  g_arena_mode = var:get(packet.key.itemdata_idx).v_int
  g_arena_mode_data = var:get(packet.key.arena_mode_data).v_int
  g_arena_id = var:get(packet.key.arena_id).v_string
  g_inArenaScn = var:has(packet.key.arena_in_scn)
  gx_outermng_pn.visible = not g_inArenaScn
  gx_innermng_pn.visible = g_inArenaScn
  gx_status_clock.visible = g_inArenaScn
  gx_watch_btn.visible = false
  gx_watch_btn.text = ui.get_text("match|goin_btn")
  g_watchOn = false
  gx_fight_lista:item_clear()
  gx_fight_listb:item_clear()
  gx_status_window.visible = true
  gx_statistics_window.visible = false
  initial_statistics()
  local match_type = GetMatchType(var)
  gx_status_type.text = match_type
  gx_status_min_type.text = match_type
  if not g_inArenaScn then
    ui_packet.game_recv_signal_insert(packet.eSTC_UI_CloseTalk, function(cmd, data)
      gx_status_window.visible = false
    end, "arena.tmp_handler")
  else
    bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, on_player_enter, "ui_match:on_player_enter")
  end
end
function OnStatusWindowToggleVisible(ctrl, vis)
  if not vis then
    if gx_innermng_pn.visible then
      gx_minimum.visible = true
    end
    ui_packet.game_recv_signal_remove(packet.eSTC_UI_CloseTalk, "arena.tmp_handler")
  end
end
function close_status_window()
  gx_innermng_pn.visible = false
  gx_status_window.visible = false
  gx_minimum.visible = false
  gx_watch_guess.visible = false
  gx_timer.suspended = true
  viewlist.gx_mainWin.visible = false
  on_player_leaveScn()
  g_members_var = {}
  g_members_item = {}
  gx_fight_lista:item_clear()
  gx_fight_listb:item_clear()
  ui_match_cmn.set_visible(false)
  g_inArenaScn = false
  bo2.remove_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_enter_scn, "ui_match:on_player_enter")
end
function on_career_tip_make(tip)
  local panel = tip.owner.parent
  local career_panel = panel:search("job")
  local pro_list = bo2.gv_profession_list:find(career_panel.svar)
  if pro_list ~= nil then
    text = sys.format("%s", pro_list.name)
    ui_widget.tip_make_view(tip.view, text)
  end
end
function get_career_idx(val)
  local pro = bo2.gv_profession_list:find(val)
  if pro == nil then
    return -1
  end
  return pro.career - 1
end
function set_career_color(pic, career_idx)
  local pro = bo2.gv_profession_list:find(career_idx)
  if pro ~= nil then
    ui_portrait.make_career_color(pic, pro)
  end
end
function RenderPlayerItem(item, var, handle)
  local name = var:get(packet.key.cha_name).v_string
  item:search("player_name").text = name
  local level = var:get(packet.key.cha_level).v_int
  item:search("level").text = sys.format("lv%d", level)
  local portrait = var:get(packet.key.cha_portrait).v_int
  local por_list = bo2.gv_portrait:find(portrait)
  if por_list ~= nil then
    item:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
  end
  local career = var:get(packet.key.player_profession).v_int
  local career_panel = item:search("job")
  local career_idx = get_career_idx(career)
  if career_idx >= 0 then
    career_panel.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", career_idx + 1)
    set_career_color(career_panel, career)
    career_panel.svar = career
  else
    career_panel.visible = false
  end
  local max_hp = 0
  local cur_hp = 0
  if handle ~= nil then
    item.svar = handle
    local obj = bo2.scn:get_scn_obj(handle)
    if obj ~= nil then
      max_hp = obj:get_atb(bo2.eAtb_HPMax)
      cur_hp = obj:get_atb(bo2.eAtb_HP)
    end
  else
    cur_hp = var:get(packet.key.cha_cur_hp).v_int
    max_hp = var:get(packet.key.cha_max_hp).v_int
  end
  item:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
  item:search("cur_hp").parent.dx = 170 * (cur_hp / max_hp)
  if var:has(packet.key.cmn_system_flag) then
    item:search("fight_flag").visible = true
    item:search("hilight").visible = true
  end
  g_members_item[name] = item
end
function add_arena_member(var)
  local side = var:get(packet.key.itemdata_idx).v_int
  local turn = var:get(packet.key.itemdata_val).v_int
  local name = var:get(packet.key.cha_name).v_string
  g_members_var[name] = var
  local list = g_fight_list[side]
  if not list then
    return
  end
  local item = list:item_insert(turn)
  item:load_style("$frame/match/status.xml", "player_item_3")
  item:search("player_name").color = g_item_back_color[side]
  RenderPlayerItem(item, var)
end
function onSelfEnterScn(obj)
  if g_inArenaScn == false then
    return
  end
  if g_members_var[obj.name] then
    gx_watch_btn.visible = true
  else
    gx_watch_btn.visible = false
    ui_match_cmn.set_visible(true)
  end
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_enter, onSelfEnterScn, "ui_match:onSelfEnterScn")
function SetWatchStatus(data)
  gx_watch_btn.enable = true
  g_watchOn = data:get(packet.key.arena_watch).v_int ~= 0
  local statusText = function()
    if g_watchOn then
      return ui.get_text("match|prepare_btn")
    else
      return ui.get_text("match|goin_btn")
    end
  end
  gx_watch_btn.text = statusText()
  ui_match_cmn.set_visible(g_watchOn)
  if g_watchOn == true then
    auto_select()
  else
    bo2.ChgCamera(0)
    bo2.player:SetTarget(bo2.player.sel_handle)
  end
end
function set_member_turn(var)
  local side = var:get(packet.key.itemdata_idx).v_int
  local turn = var:get(packet.key.itemdata_val).v_int
  local name = var:get(packet.key.cha_name).v_string
  local list = g_fight_list[side]
  if not list then
    return
  end
  local item = list:item_get(turn)
  if item == g_members_item[name] then
    return
  end
  local src_name = item:search("player_name").text
  local src_handle = item.svar
  local tar_handle = g_members_item[name].svar
  RenderPlayerItem(g_members_item[name], g_members_var[src_name], src_handle)
  RenderPlayerItem(item, g_members_var[name], tar_handle)
end
function least_number(src_num, n, direction)
  src_num = tostring(src_num)
  local len = #src_num
  local output = src_num
  if n > len then
    if direction == "R" then
      for i = 1, n - len do
        output = output .. "0"
      end
    else
      for i = 1, n - len do
        output = "0" .. output
      end
    end
  end
  return output
end
local l_cur_time = 0
local l_cur_tick = 0
function on_timer()
  local tick = sys.tick()
  local dtick = sys.dtick(tick, l_cur_tick)
  l_cur_time = g_cur_time - math.floor(dtick / 1000)
  if l_cur_time <= 0 then
    ui_match_cmn.set_timer(0, 0, 0)
    return
  end
  local ONE_MINUTE = 60
  local s = ""
  if ONE_MINUTE >= l_cur_time then
    s = sys.format(ui.get_text("match|clock_fmt"), least_number(l_cur_time, 2))
  else
    local minute = math.floor(l_cur_time / ONE_MINUTE)
    local second = l_cur_time % ONE_MINUTE
    s = sys.format(ui.get_text("match|clock_fmt_big"), least_number(minute, 2), least_number(second, 2))
  end
  gx_status_clock.text = s
  gx_status_min_clock.text = s
end
function set_status_clock(var)
  l_cur_tick = sys.tick()
  g_cur_time = var:get(packet.key.itemdata_val).v_int
  local ONE_MINUTE = 60
  local s = ""
  if ONE_MINUTE >= g_cur_time then
    s = sys.format(ui.get_text("match|clock_fmt"), least_number(g_cur_time, 2))
  else
    local minute = math.floor(g_cur_time / ONE_MINUTE)
    local second = g_cur_time % ONE_MINUTE
    s = sys.format(ui.get_text("match|clock_fmt_big"), least_number(minute, 2), least_number(second, 2))
  end
  gx_status_clock.text = s
  gx_status_min_clock.text = s
  gx_timer.suspended = false
  local num1 = math.modf(g_cur_time / 100)
  local num2 = math.modf((g_cur_time % 100 - g_cur_time % 10) / 10)
  local num3 = g_cur_time % 10
  ui_match_cmn.set_timer(num1, num2, num3)
end
local hilight_lists = function(list, on)
  local cnt = list.item_count
  for i = 1, cnt do
    local item = list:item_get(i - 1)
    item:search("fight_flag").visible = on
    item:search("hilight").visible = on
    if on == true and item:search("player_name").text == bo2.player.name then
      gx_status_window.visible = false
    end
  end
end
local hilight_player_item = function(list, turn)
  local item = list:item_get(turn)
  item:search("fight_flag").visible = true
  item:search("hilight").visible = true
  if item:search("player_name").text == bo2.player.name then
    gx_status_window.visible = false
  end
end
function set_fighter_hilight(var)
  if g_arena_mode == bo2.eMatchType_ArenaInturn or g_arena_mode == bo2.eMatchType_Act3V3 then
    hilight_lists(gx_fight_lista, false)
    hilight_lists(gx_fight_listb, false)
    local turn_a = var:get(packet.key.arena_a_turn).v_int
    hilight_player_item(gx_fight_lista, turn_a)
    local turn_b = var:get(packet.key.arena_b_turn).v_int
    hilight_player_item(gx_fight_listb, turn_b)
    if g_arena_mode == bo2.eMatchType_Act3V3 then
      local item_a = gx_fight_lista:item_get(turn_a)
      local item_b = gx_fight_listb:item_get(turn_b)
      on_pk_start(item_a, item_b)
    end
    auto_select()
  else
    hilight_lists(gx_fight_lista, true)
    hilight_lists(gx_fight_listb, true)
  end
end
local createChkTimer = function(t)
  local beg = 0
  return function()
    local now = os.time()
    local len = os.difftime(now, beg)
    local ok = len >= t
    if ok then
      beg = now
    end
    return ok
  end
end
function on_msg(msg)
  if msg.result == 0 then
    return
  end
  if bo2.player:get_flag_objmem(bo2.eFlagObjMemory_FightState) == 1 then
    ui_chat.show_ui_text_id(1162)
    return
  end
  gx_innermng_pn.visible = false
  bo2.send_variant(packet.eCTS_UI_LeaveArenaScn)
  ui_video.on_auto_end_rec_match_video()
end
local leavebtn_chk = createChkTimer(2)
function onClickLeaveButton()
  if bo2.player:get_flag_objmem(bo2.eFlagObjMemory_FightState) == 1 then
    ui_chat.show_ui_text_id(1162)
    return
  end
  if leavebtn_chk() then
    local msg = {
      callback = on_msg,
      btn_confirm = true,
      btn_cancel = true,
      modal = true
    }
    msg.text = ui.get_text("match|msg_box")
    ui_widget.ui_msg_box.show_common(msg)
  end
end
local goin_chk = createChkTimer(2)
function ClickGoinArenaScn()
  if goin_chk() then
    local var = sys.variant()
    var:set(packet.key.arena_id, g_arena_id)
    bo2.send_variant(packet.eCTS_UI_Arena_GoinWatch, var)
  end
end
local watchbtn_chk = createChkTimer(2)
function onClickWatchToggle(btn)
  if watchbtn_chk() then
    local var = sys.variant()
    var:set(packet.key.arena_watch, g_watchOn and 0 or 1)
    bo2.send_variant(packet.eCTS_UI_ArenaFighterWatch, var)
  end
end
local viewerlist_chk = createChkTimer(2)
function GetViewerList()
  if viewerlist_chk() then
    viewlist.OpenViewerPage(packet.eCTS_UI_ArenaViewerListReq, ui_match.g_arena_id)
  end
end
function show_three_game_result(var)
  ui_deathui.set_three_games_arena(var, true)
end
function show_match_result(var)
  if var:has(packet.key.item_key) then
    show_three_game_result(var)
    return
  end
  if not gx_innermng_pn.visible then
    return
  end
  local win = var:get(packet.key.arena_side).v_int
  if win < 0 then
  else
  end
  if ui_match_cmn.is_match_enable() then
    ui_match_cmn.set_visible(false)
    bo2.ChgCamera(0)
  end
  gx_minimum.visible = false
  if g_arena_mode == bo2.eMatchType_Act3V3 then
    gx_status_window.visible = false
    gx_statistics_window.visible = true
  else
    gx_status_window.visible = true
  end
end
function GetArenaLink(btn)
  local text = GetSimpleMatchType(g_arena_mode, g_arena_mode_data)
  local group1 = gx_fight_lista:item_get(0):search("player_name").text
  local group2 = gx_fight_listb:item_get(0):search("player_name").text
  text = sys.format("%s:%s VS %s", text, group1, group2)
  ui_chat.insert_arena(g_arena_id, text)
end
function on_item_mouse(panel, msg, pos, wheel)
  if msg ~= ui.mouse_lbutton_click then
    return
  end
  if ui_match_cmn.is_match_enable() == false then
    return
  end
  if not g_inArenaScn then
    return
  end
  if panel:search("fight_flag").visible == false then
    return
  end
  if msg == ui.mouse_lbutton_click then
    bo2.ChgCamera(panel.svar)
    bo2.player:SetTarget(panel.svar)
  end
end
function on_fight_chghp(obj)
  local max_hp = obj:get_atb(bo2.eAtb_HPMax)
  local cur_hp = obj:get_atb(bo2.eAtb_HP)
  local item = g_members_item[obj.name]
  if item ~= nil then
    item:search("death_color").visible = false
    item:search("hp_val").text = sys.format("%d/%d", cur_hp, max_hp)
    item:search("cur_hp").parent.dx = 170 * (cur_hp / max_hp)
  end
  if g_arena_mode == bo2.eMatchType_Act3V3 then
    on_fight_dam(obj)
  end
end
function on_chgPortrait(obj)
  local item = g_members_item[bo2.player.name]
  local portrait = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
  local por_list = bo2.gv_portrait:find(portrait)
  if por_list ~= nil then
    item:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
    bo2.player:remove_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Portrait, "ui_match:on_chgPortrait")
  end
  if g_members_var[obj.name] then
    g_members_var[obj.name]:set(packet.key.cha_portrait, portrait)
  end
end
function on_player_enter(obj, msg)
  if g_members_item[obj.name] ~= nil then
    local item = g_members_item[obj.name]
    on_fight_chghp(obj)
    g_members_item[obj.name].svar = obj.sel_handle
    auto_select()
    local portrait = obj:get_flag_int32(bo2.ePlayerFlagInt32_Portrait)
    local por_list = bo2.gv_portrait:find(portrait)
    if por_list ~= nil then
      item:search("portrait").image = sys.format("$icon/portrait/%s.png", por_list.icon)
    end
    if g_members_var[obj.name] then
      g_members_var[obj.name]:set(packet.key.cha_portrait, portrait)
    end
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, on_fight_chghp, "ui_match:on_fight_chghp")
    obj:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HPMax, on_fight_chghp, "ui_match:on_fight_chghp")
    if obj == bo2.player then
      obj:insert_on_flagmsg(bo2.eFlagType_Int32, bo2.ePlayerFlagInt32_Portrait, on_chgPortrait, "ui_match:on_chgPortrait")
    end
  end
end
function on_player_leave()
  close_status_window()
  for i = 0, 1 do
    for j = 0, g_fight_list[i].item_count - 1 do
      local panel = g_fight_list[i]:item_get(j)
      local obj = bo2.scn:get_scn_obj(panel.svar)
      if obj ~= nil then
        obj:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HP, "ui_match:on_fight_chghp")
        obj:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_HPMax, "ui_match:on_fight_chghp")
      end
    end
  end
end
bo2.insert_on_scnmsg(bo2.eScnObjKind_Player, bo2.scnmsg_self_leave, on_player_leave, "ui_match:on_player_leave")
