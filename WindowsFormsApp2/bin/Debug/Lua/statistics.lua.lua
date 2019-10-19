local pic_win = L("$image/match/statistics.png|5,166,66,27")
local pic_lose = L("$image/match/statistics.png|97,166,237,240")
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_match.packet_handle"
local player_items = {}
local team_name = {}
local pk_shanshen_use_times = 0
local pk_shoushen_use_times = 0
local pk_damage_make = 0
local pk_damage_get = 0
local pk_opponent_life_last = 0
local pk_player_life_last = 0
local pk_player_st_lost = 0
local pk_player_st_last = 0
local pk_player_last_skillid = {}
local pk_skill_use_times = 0
local pk_baoqi_use_times = 0
local pk_bisha_use_times = 0
local pk_defend_use_times = 0
local total_hp_lost = 0
local total_shanshen_use_times = 0
local total_shoushen_use_times = 0
local total_damage_make = 0
local total_player_st_cost = 0
local pk_begin_record = false
local g_win = false
local b_leaveScn = false
local g_match_record = false
function initial_statistics()
  g_win = false
  gx_matchInfo_list:item_clear()
  total_hp_lost = 0
  total_shanshen_use_times = 0
  total_shoushen_use_times = 0
  total_damage_make = 0
  total_player_st_cost = 0
  pk_player_last_skillid = {}
  pk_skill_use_times = 0
  pk_baoqi_use_times = 0
  pk_bisha_use_times = 0
  pk_defend_use_times = 0
  b_leaveScn = false
  gx_statistics_window:search("firstwin_icon").visible = false
  gx_statistics_window:search("gamblewin_icon").visible = false
  gx_statistics_window:search("personalwin_icon").visible = false
end
function on_player_leaveScn()
  local player_num = 0
  for i = 0, gx_fight_lista.item_count - 1 do
    local player_item = gx_statistics_window:search("player" .. player_num)
    player_item.mouse_able = false
    player_num = player_num + 1
  end
  player_num = 3
  for i = 0, gx_fight_listb.item_count - 1 do
    local player_item = gx_statistics_window:search("player" .. player_num)
    player_item.mouse_able = false
    player_num = player_num + 1
  end
  if b_leaveScn == false then
    local tb = ui_handson_teach.g_handsonhelp_data[bo2.ePlayerFlagInt16_HandsOn_3V3_Teammate_Delation]
    if tb and tb.handson_teach and tb.handson_teach.flicker then
      tb.handson_teach.flicker.visible = false
      tb.handson_teach.timer.suspended = true
    end
    ui_handson_teach.test_complate_match_statistic_teammate_delation(false)
  end
  b_leaveScn = true
end
function get_players_side()
  for i = 0, 1 do
    for j = 0, g_fight_list[i].item_count - 1 do
      local item = g_fight_list[i]:item_get(j)
      if item == g_members_item[bo2.player.name] then
        return i
      end
    end
  end
  return -1
end
function on_recive_statistics(var)
  local win_side = var:get(packet.key.arena_side).v_int
  local win_times = var:get(packet.key.arena_wintimes).v_int
  local gamble_times = var:get(packet.key.arena_gambletimes).v_int
  local firstwin = var:get(packet.key.arena_firstwin).v_int
  local experience = var:get(packet.key.cmn_exp).v_int
  local money = var:get(packet.key.cmn_money).v_int
  gx_statistics_window:search("personal_score"):search("personal_score").text = win_times
  local player_side = get_players_side()
  if win_side == player_side then
    gx_statistics_window:search("teamwin_icon"):search("pic").effect = ""
    gx_statistics_window:search("teamwin_icon").tip.text = ui.get_text("match|team_win")
    g_win = true
  else
    gx_statistics_window:search("teamwin_icon"):search("pic").effect = "gray"
    gx_statistics_window:search("teamwin_icon").tip.text = ui.get_text("match|team_lose")
  end
  local lose_side = -1
  if win_side == 0 then
    gx_statistics_window:search("first_result").image = pic_win
    gx_statistics_window:search("second_result").image = pic_lose
    lose_side = 1
  elseif win_side == 1 then
    gx_statistics_window:search("first_result").image = pic_lose
    gx_statistics_window:search("second_result").image = pic_win
    lose_side = 0
  else
    gx_statistics_window:search("first_result").image = pic_lose
    gx_statistics_window:search("second_result").image = pic_lose
  end
  if win_times ~= 0 then
    gx_statistics_window:search("personalwin_icon").visible = true
    gx_statistics_window:search("personalwin_icon"):search("num").text = win_times
  end
  if gamble_times ~= 0 then
    gx_statistics_window:search("gamblewin_icon").visible = true
    gx_statistics_window:search("gamblewin_icon"):search("num").text = gamble_times
  end
  if firstwin ~= 0 then
    gx_statistics_window:search("firstwin_icon").visible = true
  end
  gx_statistics_window:search("experience").text = ui.get_text("match|get_experience") .. experience
  gx_statistics_window:search("money").money = money
  if g_match_record then
    on_pk_end(lose_side)
  end
end
function on_statistics_visible(panel)
  if panel.visible == false then
    ui_handson_teach.test_complate_match_statistic_teammate_delation(false)
    return
  elseif g_win == false then
    ui_handson_teach.test_complate_match_statistic_teammate_delation(true)
  end
  local player_num = 0
  for i = 0, gx_fight_lista.item_count - 1 do
    local player_item = gx_statistics_window:search("player" .. player_num)
    player_item:search("level").text = gx_fight_lista:item_get(i):search("level").text
    player_item:search("job").image = gx_fight_lista:item_get(i):search("job").image
    player_item:search("job").irect = gx_fight_lista:item_get(i):search("job").irect
    player_item:search("portrait").image = gx_fight_lista:item_get(i):search("portrait").image
    player_item:search("portrait").irect = gx_fight_lista:item_get(i):search("portrait").irect
    player_item:search("player_name").text = gx_fight_lista:item_get(i):search("player_name").text
    if get_players_side() == 0 and g_win == false and player_item:search("player_name").text ~= bo2.player.name then
      player_item.mouse_able = true
    else
      player_item.mouse_able = false
    end
    player_item.svar = i
    player_num = player_num + 1
  end
  player_num = 3
  for i = 0, gx_fight_listb.item_count - 1 do
    local player_item = gx_statistics_window:search("player" .. player_num)
    player_item:search("level").text = gx_fight_listb:item_get(i):search("level").text
    player_item:search("job").image = gx_fight_listb:item_get(i):search("job").image
    player_item:search("job").irect = gx_fight_listb:item_get(i):search("job").irect
    player_item:search("portrait").image = gx_fight_listb:item_get(i):search("portrait").image
    player_item:search("portrait").irect = gx_fight_listb:item_get(i):search("portrait").irect
    player_item:search("player_name").text = gx_fight_listb:item_get(i):search("player_name").text
    if get_players_side() == 1 and g_win == false and player_item:search("player_name").text ~= bo2.player.name then
      player_item.mouse_able = true
    else
      player_item.mouse_able = false
    end
    player_item.svar = i
    player_num = player_num + 1
  end
  gx_statistics_window:search("damage_get"):search("damage_get").text = total_hp_lost
  gx_statistics_window:search("jink_times"):search("jink_times").text = total_shanshen_use_times
  gx_statistics_window:search("damage_make"):search("damage_make").text = total_damage_make
  gx_statistics_window:search("shoushen_times"):search("shoushen_times").text = total_shoushen_use_times
  gx_statistics_window:search("bisha_times"):search("bisha_times").text = pk_bisha_use_times
  gx_statistics_window:search("stamina_cost"):search("stamina_cost").text = total_player_st_cost
end
function on_pk_start(item_a, item_b)
  if g_match_record then
    if player_items[0] and player_items[0] == item_a then
      on_pk_end(1)
    elseif player_items[1] and player_items[1] == item_b then
      on_pk_end(0)
    else
      on_pk_end(-1)
    end
  end
  g_match_record = true
  local obj_a = bo2.scn:get_scn_obj(item_a.svar)
  local obj_b = bo2.scn:get_scn_obj(item_b.svar)
  player_items[0] = item_a
  player_items[1] = item_b
  if obj_a == nil and obj_b == nil then
    on_pk_end(-1)
    return
  elseif obj_a == nil then
    on_pk_end(0)
    return
  elseif obj_b == nil then
    on_pk_end(1)
    return
  end
  if obj_a == bo2.player or obj_b == bo2.player then
    pk_begin_record = true
    if obj_a == bo2.player then
      pk_opponent_life_last = obj_b:get_atb(bo2.eAtb_HP)
    else
      pk_opponent_life_last = obj_a:get_atb(bo2.eAtb_HP)
    end
    pk_player_life_last = bo2.player:get_atb(bo2.eAtb_HP)
    pk_shanshen_use_times = 0
    pk_shoushen_use_times = 0
    pk_damage_make = 0
    pk_damage_get = 0
    pk_player_st_lost = 0
    pk_player_st_last = bo2.player:get_atb(bo2.eAtb_Cha_ST)
    bo2.player:insert_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_ST, on_fight_chgst, "ui_match:on_fight_chgst")
    bo2.player:insert_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_Defend, on_fight_chgdef, "ui_match:on_fight_chgdef")
  end
end
function on_pk_end(rst, item)
  if g_match_record then
    g_match_record = false
  else
    return
  end
  if item ~= nil and item ~= player_items[0] and item ~= player_items[1] then
    return
  end
  local info_item = gx_matchInfo_list:item_append()
  info_item:load_style("$frame/match/statistics.xml", "match_info_item")
  info_item:search("match_num").text = ui_im.get_merge("match|match_num", nil, "num", gx_matchInfo_list.item_count)
  if rst == 0 or rst == 1 then
    info_item:search("loser"):search("portrait").image = player_items[rst]:search("portrait").image
    info_item:search("loser"):search("portrait").irect = player_items[rst]:search("portrait").irect
    info_item:search("loser"):search("name").text = player_items[rst]:search("player_name").text
    if rst == 0 then
      rst = 1
    else
      rst = 0
    end
    info_item:search("winer"):search("portrait").image = player_items[rst]:search("portrait").image
    info_item:search("winer"):search("portrait").irect = player_items[rst]:search("portrait").irect
    info_item:search("winer"):search("name").text = player_items[rst]:search("player_name").text
  else
    info_item:search("winer"):search("portrait").image = player_items[0]:search("portrait").image
    info_item:search("winer"):search("portrait").irect = player_items[0]:search("portrait").irect
    info_item:search("winer"):search("name").text = player_items[0]:search("player_name").text
    info_item:search("result_des").text = ui.get_text("match|result_unknown")
    info_item:search("loser"):search("portrait").image = player_items[1]:search("portrait").image
    info_item:search("loser"):search("portrait").irect = player_items[1]:search("portrait").irect
    info_item:search("loser"):search("name").text = player_items[1]:search("player_name").text
  end
  player_items[0] = nil
  player_items[1] = nil
  if pk_begin_record ~= true then
    return
  end
  pk_begin_record = false
  bo2.player:remove_on_flagmsg(bo2.eFlagType_Atb, bo2.eAtb_Cha_ST, "ui_match:on_fight_chgst")
  bo2.player:remove_on_flagmsg(bo2.eFlagType_ObjMemory, bo2.eFlagObjMemory_Defend, "ui_match:on_fight_chgdef")
  total_hp_lost = total_hp_lost + pk_damage_get
  total_shanshen_use_times = total_shanshen_use_times + pk_shanshen_use_times
  total_shoushen_use_times = total_shoushen_use_times + pk_shoushen_use_times
  total_damage_make = total_damage_make + pk_damage_make
  total_player_st_cost = total_player_st_cost + pk_player_st_lost
end
function on_shanshen_used(cmd, data)
  if pk_begin_record ~= true then
    return
  end
  if total_shanshen_use_times == 0 and total_shoushen_use_times == 0 and pk_shanshen_use_times == 0 and pk_shoushen_use_times == 0 then
    add_positive_point()
  end
  pk_shanshen_use_times = pk_shanshen_use_times + 1
end
function on_shoushen_used(cmd, data)
  if pk_begin_record ~= true then
    return
  end
  if total_shanshen_use_times == 0 and total_shoushen_use_times == 0 and pk_shanshen_use_times == 0 and pk_shoushen_use_times == 0 then
    add_positive_point()
  end
  pk_shoushen_use_times = pk_shoushen_use_times + 1
end
function on_skill_used(cmd, data)
  if pk_begin_record ~= true then
    return
  end
  local skillid = data:get(L("id")).v_int
  if pk_player_last_skillid[skillid] == nil then
    pk_player_last_skillid[skillid] = 1
    pk_skill_use_times = pk_skill_use_times + 1
    if pk_skill_use_times == 2 then
      add_positive_point()
    end
  end
end
function on_baoqi_used(cmd, data)
  if pk_begin_record ~= true then
    return
  end
  if pk_baoqi_use_times == 0 and pk_bisha_use_times == 0 then
    add_positive_point()
  end
  pk_baoqi_use_times = pk_baoqi_use_times + 1
end
function on_bisha_used(cmd, data)
  if pk_begin_record ~= true then
    return
  end
  if pk_bisha_use_times == 0 and pk_baoqi_use_times == 0 then
    add_positive_point()
  end
  pk_bisha_use_times = pk_bisha_use_times + 1
end
function on_fight_dam(obj)
  if pk_begin_record ~= true then
    return
  end
  if obj == bo2.player then
    local player_life_cur = obj:get_atb(bo2.eAtb_HP)
    local player_life_chg = pk_player_life_last - player_life_cur
    if player_life_chg > 0 then
      pk_damage_get = pk_damage_get + player_life_chg
    end
    pk_player_life_last = player_life_cur
    return
  end
  if pk_damage_make == 0 and total_damage_make == 0 then
    add_positive_point()
  end
  local opponent_life_cur = obj:get_atb(bo2.eAtb_HP)
  local opponent_life_chg = pk_opponent_life_last - opponent_life_cur
  if opponent_life_chg > 0 then
    pk_damage_make = pk_damage_make + opponent_life_chg
  end
  pk_opponent_life_last = opponent_life_cur
end
function on_fight_chgst(obj)
  local player_st_cur = bo2.player:get_atb(bo2.eAtb_Cha_ST)
  local player_st_chg = pk_player_st_last - player_st_cur
  if player_st_chg > 0 then
    pk_player_st_lost = pk_player_st_lost + player_st_chg
  end
  pk_player_st_last = player_st_cur
end
function on_fight_chgdef(obj)
  if pk_defend_use_times == 0 then
    add_positive_point()
  end
  pk_defend_use_times = pk_defend_use_times + 1
end
function onClickStaLeaveButton()
  if b_leaveScn then
    gx_statistics_window.visible = false
    return
  end
  local msg = {
    text = ui.get_text("match|msg_box"),
    modal = true,
    btn_confirm = 1,
    btn_cancel = 1,
    callback = function(data)
      if data.result == 1 then
        bo2.send_variant(packet.eCTS_UI_LeaveArenaScn)
        ui_video.on_auto_end_rec_match_video()
        gx_statistics_window.visible = false
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_vote_mouse(panel, msg, pos, wheel)
  if msg == ui.mouse_lbutton_down then
    local name = panel:search("player_name").text
    if name ~= nil then
      local arg = sys.variant()
      arg:set("cha_name", name)
      local msg = {
        text = sys.mtf_merge(arg, ui.get_text("match|delate_player")),
        modal = true,
        btn_confirm = 1,
        btn_cancel = 1,
        timeout = 10000,
        callback = function(data)
          if data.result == 1 then
            local v = sys.variant()
            v:set(packet.key.itemdata_idx, panel.svar)
            bo2.send_variant(packet.eCTS_UI_DelateTeammate, v)
            panel.mouse_able = false
            ui_handson_teach.test_complate_match_statistic_teammate_delation(false)
          end
        end
      }
      ui_widget.ui_msg_box.show_common(msg)
    end
  end
end
function on_ask_delation(cmd, var)
  local name = var:get(packet.key.target_name).v_string
  local arg = sys.variant()
  arg:set("cha_name", name)
  local msg = {
    text = sys.mtf_merge(arg, ui.get_text("match|delate_response")),
    modal = false,
    btn_confirm = 1,
    btn_cancel = 1,
    timeout = 60000,
    callback = function(data)
      if data.result == 1 then
        var:erase(packet.key.target_name)
        bo2.send_variant(packet.eCTS_UI_DelationResponse, var)
      end
    end
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function add_positive_point()
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_AddPositivePoint, v)
end
reg(packet.eSTC_UI_PK_KnightPKUseShanShen, on_shanshen_used, sig)
reg(packet.eSTC_UI_PK_KnightPKUseShouShen, on_shoushen_used, sig)
reg(packet.eSTC_UI_PK_KnightPKUseSkill, on_skill_used, sig)
reg(packet.eSTC_UI_PK_KnightPKUseBaoQi, on_baoqi_used, sig)
reg(packet.eSTC_UI_AskDelation, on_ask_delation, sig)
