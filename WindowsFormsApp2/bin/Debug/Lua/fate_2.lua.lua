local g_ci_max_portrait_size = 19
local g_timer_count = 0
local g_self_data = {}
local ciInitTokenPerDay = 2
function get_current_score()
  return g_self_data._score
end
local g_team_data = {}
local g_public_info = {}
local g_auto_join_notify = false
function on_init_once()
  g_self_data = {
    request_id = 0,
    request_common_id = 0,
    has_team = 0,
    self_type = 0,
    self_state = bo2.eFatePlayerState_Max,
    match_time = 0,
    _score = 0,
    token = ciInitTokenPerDay,
    award_token = ciInitTokenPerDay
  }
  g_parter_data = {name = nil, level = 0}
  g_team_data = {
    request_id = 0,
    request_common_id = 0,
    team_state = 0,
    team_type = 0,
    only_id = 0,
    parter_name = nil,
    parter_level = 0,
    parter_only_id = 0,
    parter_professions = 0,
    parter_type = 0,
    parter_portrait = 0,
    history = {}
  }
  g_public_info = {request_id = 0, public_data = nil}
end
local ci_fate_cooldown_award = 30029
local ci_fate_cooldown_token_excel_index = 30030
on_init_once()
g_portrait_path = "$icon/portrait/"
function on_get_portrait_icon(id)
  local portrait_list = bo2.gv_portrait:find(id)
  if portrait_list ~= nil then
    return g_portrait_path .. portrait_list.icon .. ".png"
  end
end
function set_self_state(state)
  g_self_data.self_state = state
end
function is_self_state(state)
  if g_self_data.self_state == nil then
    return false
  end
  return g_self_data.self_state == state
end
function on_click_send_application()
  if is_self_state(bo2.eFatePlayerState_Max) or is_self_state(bo2.eFatePlayerState_None) then
    do
      local v = sys.variant()
      local mtf_text = ui.get_text("fate|fate_single_apply")
      for i = 0, 5 do
        local info = ui.member_get_by_idx(i)
        if info ~= nil and info.only_id ~= L("0") and info.only_id ~= bo2.player.only_id then
          v:set(packet.key.pet_only_id, info.only_id)
          mtf_text = ui_widget.merge_mtf({
            name = sys.format("<q_user:%s,00ff00>", info.name)
          }, ui.get_text("fate|fate_apply"))
          break
        end
      end
      local function on_msg_callback(msg)
        if msg.result == 1 then
          bo2.send_variant(packet.eCTS_CavalierChampionship_FateApplication, v)
          return
        end
      end
      local msg = {callback = on_msg_callback, text = mtf_text}
      ui_widget.ui_msg_box.show_common(msg)
      return
    end
  end
  local v = sys.variant()
  for i = 0, 5 do
    local info = ui.member_get_by_idx(i)
    if info ~= nil and info.only_id ~= bo2.player.only_id then
      v:set(packet.key.pet_only_id, info.only_id)
      break
    end
  end
  bo2.send_variant(packet.eCTS_CavalierChampionship_FateApplication, v)
end
function on_click_cancel_player_match()
  bo2.send_variant(packet.eCTS_CavalierChampionship_FateCancelPlayerMatch, v)
end
function on_click_set_master()
  local on_msg_callback = function(msg)
    if msg.result == 1 then
      bo2.send_variant(packet.eCTS_CavalierChampionship_SetFateMaster, v)
      return
    end
  end
  local msg = {
    callback = on_msg_callback,
    text = ui_widget.merge_mtf({
      name = g_team_data.parter_name
    }, ui.get_text("fate|fate_set_master_confirm"))
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_click_leave_team()
  local on_msg_callback = function(msg)
    if msg.result == 1 then
      bo2.send_variant(packet.eCTS_CavalierChampionship_BreakFateTeam, v)
      return
    end
  end
  local msg = {
    callback = on_msg_callback,
    text = ui.get_text("fate|fate_leave_confirm")
  }
  ui_widget.ui_msg_box.show_common(msg)
end
function on_click_close()
  w_main.visible = false
end
function on_esc_stk_visible(w, vis)
  if vis ~= true then
    ui_fate.new_challenger_text.visible = false
  end
  ui_widget.on_esc_stk_visible(w, vis)
  local vData = sys.variant()
  if vis then
    stop_match_timer()
    vData:set(packet.key.pet_hole_reopen, 1)
    if g_self_data.request_id ~= 0 then
      vData:set(packet.key.chat_cha_id_list, g_self_data.request_id)
    end
    if g_self_data.request_common_id ~= 0 then
      vData:set(packet.key.chat_channel_id, g_self_data.request_common_id)
    end
    if g_team_data.request_id ~= 0 then
      vData:set(packet.key.group_request_id, g_team_data.request_id)
    end
    if g_team_data.request_common_id ~= 0 then
      vData:set(packet.key.group_union_request_id, g_team_data.request_common_id)
    end
    if g_public_info.request_id ~= 0 then
      vData:set(packet.key.dexp_id, g_public_info.request_id)
    end
  else
    vData:set(packet.key.pet_hole_reopen, 0)
  end
  bo2.send_variant(packet.eCTS_CavalierChampionship_FateRequestUIData, vData)
end
function on_timer_enter_scene()
end
function run()
  w_main.visible = true
end
function on_init_three_one()
  local selected_list = ui_fate.w_main:search("selected_list")
  for i = 0, 1 do
    local rand_name = sys.format("random%d", i)
    local rand_control = selected_list:search(rand_name)
    if sys.check(rand_control) then
      rand_control.tip.text = g_default_tip_text
      rand_control.visible = false
      local rand_portrait = rand_control:search("portrait")
      if sys.check(rand_portrait) then
        rand_portrait.image = g_default_portrait_uri
        rand_portrait.effect = ""
      end
      local rand_hightlight = rand_control:search("highlight_select")
      if sys.check(rand_hightlight) then
        rand_hightlight.visible = false
      end
    end
  end
end
function runf_act(v_data)
  init_act_data_by_index(v_data.v_int)
end
function stk_push_new_line(stk)
  stk:push("\n")
end
function stk_push_sep(stk)
  stk:push([[
<tf+:micro>
<sep>
<tf->]])
end
function init_act_data_by_index(iAct)
  local act_excel = bo2.gv_cavalier_championship_act:find(iAct + 100)
  if sys.check(act_excel) ~= true then
    return
  end
  local act_award_data = bo2.gv_cavalier_championship_award:find(act_excel.act_award)
  if sys.check(act_award_data) ~= true then
    return
  end
  local obj_level = ui.safe_get_atb(bo2.eAtb_Level)
  local make_act_common_award = function(act_award_data, obj_level, bDouble)
    local stk = sys.stack()
    local mtf_award_score = sys.format("<c+:00ff00>%d<c->", act_award_data.award_base_money)
    stk:push(ui_widget.merge_mtf({award_score = mtf_award_score}, ui.get_text("fate|fate_act_award")))
    return stk.text
  end
  local common_award_text = make_act_common_award(act_award_data, obj_level, false)
  local npc_list = ui_fate.w_main:search("npc_list")
  local iActIndex = iAct - 1
  if iActIndex < 0 or iActIndex > 8 then
    return
  end
  local size = bo2.gv_cavalier_championship_npc.size
  for i = 0, size - 1 do
    local excel_data = bo2.gv_cavalier_championship_npc:get(i)
    local in_pos_index = -1
    if excel_data.in_act[iActIndex] ~= 0 then
      in_pos_index = excel_data.in_pos[iActIndex]
    end
    if in_pos_index >= 0 and in_pos_index <= g_ci_max_portrait_size then
      local cha_list_data = bo2.gv_cha_list:find(excel_data.cha_list_id)
      if sys.check(cha_list_data) then
        local cha_pic = bo2.gv_cha_pic:find(cha_list_data.pic)
        if sys.check(cha_pic) then
          local pos_index = sys.format(L("c%d"), in_pos_index)
          local item_control = npc_list:search(pos_index)
          if sys.check(item_control) then
            local function init_tip_text(tip, name, npc_excel)
              local stk = sys.stack()
              stk:push(name)
              stk_push_new_line(stk)
              stk:push([[
<tf+:micro>
<sep>
<tf->]])
              stk:push(common_award_text)
              tip.text = stk.text
            end
            init_tip_text(item_control.tip, cha_list_data.name, excel_data)
            local item_protrait = item_control:search("portrait")
            if sys.check(item_protrait) then
              item_protrait.image = g_portrait_path .. cha_pic.head_icon
              item_protrait.var:set(packet.key.cha_id, excel_data.cha_list_id)
            end
            local back_color = item_control:search("back_pic")
            if sys.check(back_color) then
              if excel_data.client_mark ~= 0 then
                back_color.visible = false
                back_color.color = ui.make_color("FFFFFF")
                back_color.var:set("name", cha_list_data.name)
              else
                back_color.color = ui.make_color("FFFFFF")
                back_color.visible = false
              end
            end
          end
        end
      end
    end
  end
end
function on_init_act_data()
  local npc_list = ui_fate.w_main:search("npc_list")
  for i = 0, 19 do
    local pos_index = sys.format("c%d", i)
    local item_control = npc_list:search(pos_index)
    if sys.check(item_control) then
      item_control.tip.text = g_default_tip_text
      local item_protrait = item_control:search("portrait")
      if sys.check(item_protrait) then
        item_protrait.image = g_default_portrait_uri
        item_protrait.effect = ""
      end
      local item_highlight = item_control:search("highlight_select")
      if sys.check(item_highlight) then
        item_highlight.visible = false
      end
      local back_color = item_control:search("back_pic")
      if sys.check(back_color) then
        back_color.visible = false
      end
    end
  end
end
function set_act_portrait(act)
  local current_act = act - 1
  local old_name = sys.format("r%d", current_act)
  local act_list = ui_fate.w_main:search("act_list")
  local old_control = act_list:search(old_name)
  local strPortaitName = sys.format("$icon/item/tz/tz000%d.png", act)
  local portrait_control = old_control:search("portrait")
  local close_control = old_control:search("close")
  if sys.check(close_control) then
    close_control.visible = false
  end
  if sys.check(portrait_control) ~= true and sys.check(old_control) ~= true then
    return
  end
  portrait_control.effect = ""
  local varData
  if g_team_data ~= nil and g_team_data.act ~= nil and current_act < g_team_data.act - 1 and g_team_data.history ~= nil and g_team_data.history[current_act] ~= nil then
    varData = g_team_data.history[current_act]
  end
  if varData == nil then
    portrait_control.visible = false
    return
  end
  if varData.is_player == true then
    local iExcelId = varData.master
    portrait_control.visible = true
    portrait_control.image = on_get_portrait_icon(iExcelId)
    portrait_control.effect = "gray"
    close_control.visible = true
    return
  end
  local iExcelId = varData.master
  local excel_data = bo2.gv_cavalier_championship_npc:find(iExcelId)
  if sys.check(excel_data) then
    local cha_list_data = bo2.gv_cha_list:find(excel_data.cha_list_id)
    if sys.check(cha_list_data) then
      local cha_pic = bo2.gv_cha_pic:find(cha_list_data.pic)
      if sys.check(cha_pic) then
        strPortaitName = g_portrait_path .. cha_pic.head_icon
        portrait_control.visible = true
        portrait_control.image = strPortaitName
        portrait_control.effect = "gray"
        close_control.visible = true
      end
    end
  end
end
function init_act_portrait()
  for i = 1, 8 do
    set_act_portrait(i)
  end
end
function stop_match_timer()
  ui_fate.g_timer_player_match.suspended = true
end
function on_timer_player_match()
  if ui_fate.w_main.visible ~= true or is_self_state(bo2.eFatePlayerState_WaitingMatch) ~= true then
    stop_match_timer()
    return
  end
  on_set_waiting_match_data()
end
function on_set_award_tips(w_control, excel)
  if sys.check(w_control) ~= true then
    return
  end
  local eLevel = ui.safe_get_atb(bo2.eAtb_Level)
  local stk = sys.stack()
  if sys.check(excel) then
    stk:push(ui_widget.merge_mtf({
      next_score = excel.iMinScore
    }, sys.format(ui.get_text("fate|fate_next_score"))))
    stk_push_sep(stk)
    if excel.award_exp_persent > 0 then
      local _exp = excel.award_exp_persent * eLevel
      local exp_text = sys.format("<c+:00FF00>%d<c->", _exp)
      stk:push(ui_widget.merge_mtf({exp = exp_text}, sys.format(ui.get_text("fate|fate_score_exp"))))
      stk_push_new_line(stk)
    end
    if 0 < excel.award_money_persent then
      local _money = excel.award_money_persent * eLevel
      local award_money
      if excel.award_money_type == 0 then
        award_money = sys.format("<m:%d>", _money)
      else
        award_money = sys.format("<bm:%d>", _money)
      end
      stk:push(ui_widget.merge_mtf({money = award_money}, sys.format(ui.get_text("fate|fate_score_money"))))
    end
    if excel.award_exp_persent > 0 then
      local _item = sys.format("<i:%d>", excel.award_item_id)
      stk:push(ui_widget.merge_mtf({
        item = _item,
        count = excel.award_item_count
      }, sys.format(ui.get_text("fate|fate_score_item"))))
    end
  else
    stk:push(ui.get_text("fate|fate_full_award"))
  end
  local iRank = g_self_data.rank_id
  stk_push_sep(stk)
  local rank_award_excel_size = bo2.gv_fate_rank_award.size
  if iRank and iRank > 0 and iRank < 100 then
    for i = 0, rank_award_excel_size - 1 do
      local rank_award_excel = bo2.gv_fate_rank_award:get(i)
      if sys.check(rank_award_excel) and iRank <= rank_award_excel.iRankId then
        local rank_text = sys.format("<c+:00ff00>%d<c->", rank_award_excel.iRankId)
        stk:push(ui_widget.merge_mtf({rank_id = rank_text}, sys.format(ui.get_text("fate|fate_award_rank_text"))))
        stk_push_sep(stk)
        local money_text = sys.format("<m:%d>", rank_award_excel.award_money_persent * eLevel)
        stk:push(ui_widget.merge_mtf({money = money_text}, sys.format(ui.get_text("fate|fate_score_money"))))
        stk_push_new_line(stk)
        local repute_text = sys.format("<c+:00ff00>%d<c->", rank_award_excel.award_repute)
        stk:push(ui_widget.merge_mtf({repute = repute_text}, sys.format(ui.get_text("fate|fate_rank_repute"))))
        break
      end
    end
  elseif rank_award_excel_size > 0 then
    local rank_award_excel = bo2.gv_fate_rank_award:get(rank_award_excel_size - 1)
    if sys.check(rank_award_excel) then
      local rank_text = sys.format("<c+:00ff00>%d<c->", rank_award_excel.iRankId)
      stk:push(ui_widget.merge_mtf({rank_id = rank_text}, sys.format(ui.get_text("fate|fate_award_rand_data"))))
      stk_push_sep(stk)
      local money_text = sys.format("<m:%d>", rank_award_excel.award_money_persent * eLevel)
      stk:push(ui_widget.merge_mtf({money = money_text}, sys.format(ui.get_text("fate|fate_score_money"))))
      stk_push_new_line(stk)
      local repute_text = sys.format("<c+:00ff00>%d<c->", rank_award_excel.award_repute)
      stk:push(ui_widget.merge_mtf({repute = repute_text}, sys.format(ui.get_text("fate|fate_rank_repute"))))
    end
  end
  w_control.tip.text = stk.text
end
function on_set_score_data()
  local lb_award_data = ui_fate.w_main:search("lb_award_data")
  local stk = sys.stack()
  if bo2.IsCoolDownOver(ci_fate_cooldown_token_excel_index) ~= true then
    g_self_data.token = 0
  end
  local award_token_index = 0
  if bo2.IsCoolDownOver(ci_fate_cooldown_award) ~= true then
    g_self_data.award_token = 0
  end
  award_token_index = ciInitTokenPerDay - g_self_data.award_token
  local token_text = sys.format("<c+:00ff00>%d<c->", g_self_data.token)
  stk:push(ui_widget.merge_mtf({token = token_text}, ui.get_text("fate|fate_token")))
  local mtf_data = {}
  local _act = 0
  if g_team_data.act ~= nil then
    _act = g_team_data.act - 1
  end
  mtf_data.act = sys.format("<c+:00ff00>%d<c->", _act)
  mtf_data._score = sys.format("<c+:00ff00>%d<c->", g_self_data._score)
  stk:push(ui_widget.merge_mtf(mtf_data, ui.get_text("fate|fate_award_mtf")))
  local next_award_score = 0
  local next_award_score_size = bo2.gv_fate_score_award.size
  local pScoreAwardExcel
  for i = award_token_index, next_award_score_size do
    local pExcel = bo2.gv_fate_score_award:get(i)
    if sys.check(pExcel) and pExcel.iMinScore > g_self_data._score then
      pScoreAwardExcel = pExcel
      break
    end
  end
  if sys.check(pScoreAwardExcel) then
    local next_award_score_text = sys.format("<c+:00ff00>%d<c->", pScoreAwardExcel.iMinScore)
    stk:push(ui_widget.merge_mtf({award_score = next_award_score_text}, ui.get_text("fate|fate_award_score_data")))
  else
    stk:push(ui.get_text("fate|fate_no_more_score_award"))
  end
  if g_self_data.rank_id and 0 < g_self_data.rank_id then
    mtf_data.rank_id = sys.format("<c+:00ff00>%d<c->", g_self_data.rank_id)
    stk:push(ui_widget.merge_mtf(mtf_data, ui.get_text("fate|fate_award_rank")))
  else
    stk:push(ui_widget.merge_mtf(mtf_data, ui.get_text("fate|fate_award_no_rank")))
  end
  on_set_award_tips(lb_award_data, pScoreAwardExcel)
  lb_award_data.mtf = stk.text
  lb_award_data.parent:tune("lb_award_data")
end
function on_set_waiting_match_data()
  on_set_score_data()
  local lb_history_data = ui_fate.w_main:search("lb_history_data")
  g_self_data.match_time = g_self_data.match_time + 1
  local get_full_time = function(second)
    local wstr_text = L("")
    local iHour = math.floor(second / 3600)
    local v = math.fmod(second, 3600)
    local iMinute = math.floor(v / 60)
    local iSecond = math.fmod(v, 60)
    local stk = sys.stack()
    if iHour > 0 then
      stk:push(ui_widget.merge_mtf({houre = iHour}, ui.get_text("fate|fate_hour")))
    end
    local strMinute
    if iMinute >= 10 then
      strMinute = sys.format("%d", iMinute)
    else
      strMinute = sys.format("0%d", iMinute)
    end
    stk:push(ui_widget.merge_mtf({minute = strMinute}, ui.get_text("fate|fate_minute")))
    if iSecond >= 10 then
      strMinute = sys.format("%d", iSecond)
    else
      strMinute = sys.format("0%d", iSecond)
    end
    stk:push(ui_widget.merge_mtf({second = strMinute}, ui.get_text("fate|fate_second")))
    return stk.text
  end
  lb_history_data.mtf = ui_widget.merge_mtf({
    time = get_full_time(g_self_data.match_time)
  }, ui.get_text("fate|fate_self_match"))
  lb_history_data.parent:tune("lb_history_data")
  if g_self_data.match_time > 15 then
    btn_player_match.visible = true
    local dx = lb_history_data.dx / 2 + btn_player_match.dx / 2 + 20
    btn_player_match.margin = ui.rect(dx, 0, 0, 0)
  else
    btn_player_match.visible = false
  end
end
function on_init_all_button()
  ui_fate.w_group_cell.parent.visible = false
  btn_player_match.visible = false
  local fate_time = ui_fate.w_main:search("fate_time")
  fate_time.visible = false
end
function on_init_null_data()
  on_init_all_button()
  on_init_act_data()
  init_act_portrait(nil)
  on_init_three_one()
  on_set_score_data()
  local lb_history_data = ui_fate.w_main:search("lb_history_data")
  lb_history_data.mtf = ui.get_text("fate|fate_click_apply")
  lb_history_data.parent:tune("lb_history_data")
end
function on_init_new_act_data()
  if g_self_data.self_type == bo2.eFatePlayerType_Master then
    local lb_history_data = ui_fate.w_main:search("lb_history_data")
    lb_history_data.mtf = ui.get_text("fate|fate_group_apply")
    lb_history_data.parent:tune("lb_history_data")
  else
    local lb_history_data = ui_fate.w_main:search("lb_history_data")
    lb_history_data.mtf = ui.get_text("fate|fate_captain_apply")
    lb_history_data.parent:tune("lb_history_data")
  end
end
function on_set_fight_data()
  init_act_portrait(nil)
  on_init_three_one()
  local lb_history_data = ui_fate.w_main:search("lb_history_data")
  lb_history_data.mtf = ui.get_text("fate|fate_chanllenge")
  lb_history_data.parent:tune("lb_history_data")
end
function on_set_waiting_group_confirm()
  init_act_portrait(nil)
  on_init_three_one()
  local lb_history_data = ui_fate.w_main:search("lb_history_data")
  lb_history_data.mtf = ui.get_text("fate|fate_wait_group_confirm")
  lb_history_data.parent:tune("lb_history_data")
end
function on_refresh_self_data()
  if g_self_data.self_state == bo2.eFatePlayerState_None then
    on_init_null_data()
  elseif g_self_data.self_state == bo2.eFatePlayerState_GroupWaiting then
    on_init_new_act_data()
  elseif g_self_data.self_state == bo2.eFatePlayerState_Fighting then
    on_set_fight_data()
  elseif g_self_data.self_state == bo2.eFatePlayerState_GroupConfirm then
    on_set_waiting_group_confirm()
  elseif g_self_data.self_state == bo2.eFatePlayerState_Matching then
    local lb_history_data = ui_fate.w_main:search("lb_history_data")
    lb_history_data.mtf = ui.get_text("fate|fate_mathing")
    lb_history_data.parent:tune("lb_history_data")
  elseif g_self_data.self_state == bo2.eFatePlayerState_WaitingEnter then
    local lb_history_data = ui_fate.w_main:search("lb_history_data")
    local scn = bo2.scn
    if sys.check(scn) and sys.check(scn.excel) and scn.excel.id > 300 and scn.excel.id < 400 then
      lb_history_data.mtf = ui.get_text("fate|fate_wait_enter")
    else
      lb_history_data.mtf = ui.get_text("fate|fate_click_enter")
    end
    lb_history_data.parent:tune("lb_history_data")
  end
  on_set_score_data()
end
function on_refresh_team_data()
  if g_team_data.only_id == nil or g_team_data.only_id == 0 or g_team_data.only_id == L("") or g_team_data.only_id == L("0") then
    ui_fate.w_group_cell.parent.visible = false
    return
  end
  if g_team_data.parter_only_id ~= 0 then
    ui_fate.w_group_cell.parent.visible = true
    local lb_name = ui_fate.w_group_cell:search("name")
    lb_name.text = g_team_data.parter_name
    local pic_portrait = ui_fate.w_group_cell:search("portrait")
    pic_portrait.image = on_get_portrait_icon(g_team_data.parter_portrait)
    local lb_level = ui_fate.w_group_cell:search("level")
    lb_level.text = sys.format(L("Lv%d"), g_team_data.parter_level)
    local set_career_pic = function(pic, career)
      local pro = bo2.gv_profession_list:find(career)
      local career_idx = 0
      if pro == nil then
        career_idx = 1
      else
        career_idx = pro.career
      end
      pic.image = sys.format("$image/personal/32x32/%d.png|0,0,27,30", career_idx)
    end
    local pic_career = ui_fate.w_group_cell:search("career")
    set_career_pic(pic_career, g_team_data.parter_professions)
    local lb_current_info = ui_fate.w_group_cell:search("lb_current_info")
    if g_team_data.team_state == bo2.eFateTeam_PrePare or g_team_data.team_state == bo2.eFateTeam_FaildCurrentAct or g_team_data.team_state == bo2.eFateTeam_Clear then
      lb_current_info.visible = false
    else
      lb_current_info.visible = false
    end
    local bVisSetMasterButton = false
    w_team_btn.visible = false
    if g_team_data.team_state == bo2.eFateTeam_Retry or g_team_data.team_state == bo2.eFateTeam_NewAct then
      w_team_btn.visible = true
      if g_self_data.self_type == bo2.eFatePlayerType_Master and g_team_data.parter_type == bo2.eFatePlayerType_Servant then
        bVisSetMasterButton = true
      end
    elseif g_team_data.team_state == bo2.eFateTeam_Fight then
      local scn = bo2.scn
      if sys.check(scn) and (scn.excel.id < 320 or scn.excel.id > 330) then
        w_team_btn.visible = true
      end
    end
    btn_set_master.visible = bVisSetMasterButton
  end
  init_act_portrait()
end
function on_handle_fate_data(cmd, data)
  if data:has(packet.key.ui_begin) then
    on_init_once()
    set_self_state(bo2.eFatePlayerState_Max)
    on_init_null_data()
    return
  end
  local request_id = data:get(packet.key.chat_cha_id_list).v_int
  local request_common_id = data:get(packet.key.chat_channel_id).v_int
  local load_self_data = true
  if request_id > 0 then
    if g_self_data.request_id == request_id then
      load_self_data = false
    end
    g_self_data.request_id = request_id
  else
    load_self_data = false
  end
  if request_common_id > 0 and g_self_data.request_common_id ~= request_common_id then
    g_self_data.request_common_id = request_common_id
  end
  if data:has(packet.key.action_time) then
    set_self_state(bo2.eFatePlayerState_WaitingMatch)
    g_self_data.match_time = data:get(packet.key.action_time).v_int
    on_init_null_data()
    g_timer_player_match.suspended = false
    on_set_waiting_match_data()
    return
  end
  btn_player_match.visible = false
  stop_match_timer()
  if load_self_data == true then
    set_self_state(data:get(packet.key.cmn_state).v_int)
    g_self_data.self_type = data:get(packet.key.cmn_type).v_int
    g_self_data._score = data:get(packet.key.fate_score).v_int
    g_self_data.rank_id = data:get(packet.key.ranklist_id).v_int
    g_team_data.only_id = data:get(packet.key.group_id).v_string
  end
  if data:has(packet.key.state_cannel_excel_id) then
    g_team_data.only_id = 0
    g_team_data.request_id = 0
    g_team_data.request_common_id = 0
  end
  local _team_request_id = data:get(packet.key.group_request_id).v_int
  local _team_member_request_id = data:get(packet.key.group_union_request_id).v_int
  if _team_request_id > 0 and g_team_data.request_id ~= _team_request_id then
    g_team_data.request_id = _team_request_id
    g_team_data.act = data:get(packet.key.fate_act).v_int
    g_team_data.team_state = data:get(packet.key.group_alloc_mode).v_int
    g_team_data.team_type = data:get(packet.key.group_readygo).v_int
  end
  if _team_member_request_id > 0 and g_team_data.request_common_id ~= _team_member_request_id then
    g_team_data.only_id = data:get(packet.key.group_id).v_string
    g_team_data.request_common_id = _team_member_request_id
    g_team_data.parter_name = data:get(packet.key.group_member_name).v_string
    g_team_data.parter_level = data:get(packet.key.cha_level).v_int
    g_team_data.parter_only_id = data:get(packet.key.cha_onlyid).v_string
    g_team_data.parter_professions = data:get(packet.key.sociality_playercareer).v_int
    g_team_data.parter_type = data:get(packet.key.serial_no).v_int
    g_team_data.parter_portrait = data:get(packet.key.cha_portrait).v_int
    g_team_data.history = {}
    local all_data = data:get(packet.key.ui_cd_view_cell_data)
    local all_data_size = all_data.size
    for i = 0, all_data_size - 1 do
      local history_data = all_data:fetch_v(i)
      g_team_data.history[i] = {
        is_player = history_data:get(packet.key.is_knight_fight).v_int == 1,
        master = history_data:get(packet.key.fate_master).v_int,
        servant = history_data:get(packet.key.fate_servant).v_int
      }
    end
  end
  if data:has(packet.key.fate_npc_master) then
    if ui_fate.w_main.visible == false then
      ui_fate.w_main.visible = true
    end
    init_act_data_by_index(g_team_data.act)
    local select_table = {}
    local v_data = data:get(packet.key.fate_npc_master)
    for i = 0, 1 do
      select_table[i] = v_data:fetch_v(i).v_int
    end
    begin_random_npc(select_table)
  end
  on_refresh_self_data()
  on_refresh_team_data()
end
function on_handle_cooldown_token(cmd, data)
  local iExcelId = data:get(packet.key.cooldown_id).v_int
  local token = data:get(packet.key.cooldown_token).v_int
  if iExcelId == ci_fate_cooldown_token_excel_index then
    local mb_data = bo2.gv_cooldown_list:find(iExcelId)
    if mb_data ~= nil then
      g_self_data.token = token
    end
  elseif iExcelId == ci_fate_cooldown_award then
    local mb_data = bo2.gv_cooldown_list:find(iExcelId)
    if mb_data ~= nil then
      g_self_data.award_token = token
    end
  end
end
function on_fate_self_enter()
  local function on_time_load_finish()
    local scn = bo2.scn
    if sys.check(scn) ~= true then
      return
    end
    if scn.excel.id >= 310 and scn.excel.id < 330 then
      ui_fate.w_main.visible = false
      return
    end
    if g_auto_join_notify == true then
      g_auto_join_notify = false
      local _text = ui.get_text("fate|fate_auto_join")
      ui_tool.note_insert(_text, L("FF00FF00"))
      ui_fate.w_main.visible = true
    end
  end
  bo2.AddTimeEvent(1, on_time_load_finish)
end
function on_handle_auto_join_message(cmd, data)
  g_auto_join_notify = true
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_fate_self_enter, "ui_fate.on_self_enter_finish")
ui_packet.recv_wrap_signal_insert(packet.eSTC_Fate_AutoJoinMessage, on_handle_auto_join_message, "ui_fate.on_handle_auto_join_message")
local sig_name = "ui_fate:on_handle_fate_data"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Cavalier_Fate_GetData, on_handle_fate_data, sig_name)
sig_name = "ui_fate:on_signal_cooldown_token"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_CooldownToken, on_handle_cooldown_token, sig_name)
function run_test()
  g_team_data.act = 1
  init_act_data_by_index(1)
  local select_table = {}
  select_table[0] = 1001
  select_table[1] = 1002
  begin_random_npc(select_table)
end
local g_select_table = {}
local g_count_table = {}
local g_three_select_table = {}
local g_selected_data_count = 0
local cRandomState_Begin = 0
local cRandomState_R19 = 1
local cRandomState_R3 = 2
local cRandomState_Anime = 3
local g_random_state = cRandomState_Begin
local g_r19_tick_0 = 20
local g_r19_tick_1 = 40
local g_r19_tick_2 = 90
local g_total_tick = 150
local g_three_select_two_time = 0
local g_temp_count = 0
local g_r3_tick = 50
local g_anime_tick = 10
local g_server_select_index = 0
local g_has_select_data = 0
function on_set_timmer()
  g_timer_enter.suspended = false
end
function on_begin_random_data(iSelect)
  local new_challenger = ui_fate.w_main:search("new_challenger")
  new_challenger.visible = false
  on_set_timmer()
  on_init_three_one()
  g_timer_count = g_total_tick
  g_tick_times = g_total_tick
  g_random_state = cRandomState_R19
  g_selected_data_count = 0
  g_server_select_index = iSelect
  g_select_table = {}
  g_three_select_table = {}
  g_index = bo2.rand(0, 19)
  local bIndex = g_index % 2 == 0
  g_index_2p = bo2.rand(0, 19)
  local b2PIndex = g_index_2p % 2 == 0
  local iCount = 0
  while bIndex ~= b2PIndex do
    g_index_2p = bo2.rand(0, 19)
    b2PIndex = g_index_2p % 2 == 0
    iCount = iCount + 1
    if iCount >= 30 then
      break
    end
  end
  g_first_node = 1
  g_count_table = {}
  g_count_table[0] = bo2.rand(g_r19_tick_1 + 10, g_r19_tick_2)
  g_count_table[1] = bo2.rand(g_r19_tick_0, g_r19_tick_1)
  g_has_select_data = 0
  local npc_list = ui_champion.w_main:search("npc_list")
  for i = 0, g_ci_max_portrait_size do
    local old_name = sys.format("c%d", i)
    local old_control = npc_list:search(old_name)
    if sys.check(old_control) then
      old_control:search("highlight_select").visible = false
      old_control:search("portrait").effect = ""
    end
  end
end
function on_timer_anime()
  g_tick_times = g_tick_times - 1
  if g_tick_times <= 0 then
    local new_name = sys.format("random%d", 0)
    local selected_list = ui_fate.w_main:search("selected_list")
    local new_control = selected_list:search(new_name)
    local new_portrait = new_control:search("portrait")
    local act_name = sys.format("r%d", g_team_data.act - 1)
    local act_list = ui_fate.w_main:search("act_list")
    local act_control = act_list:search(act_name)
    local act_portrait = act_control:search("portrait")
    act_portrait.visible = true
    act_portrait.image = new_portrait.image
    act_control.tip.text = new_control.tip.text
    new_control:search("highlight_select").visible = false
    for i = 0, 19 do
      local old_name = sys.format("c%d", i)
      local npc_list = ui_fate.w_main:search("npc_list")
      local old_control = npc_list:search(old_name)
      if sys.check(old_control) then
        old_control:search("portrait").effect = "gray"
      end
    end
    for i = 0, 1 do
      local random_data = sys.format("random%d", i)
      local random_control = selected_list:search(random_data)
      if sys.check(random_control) then
        local random_portrait = new_control:search("portrait")
        random_portrait.effect = ""
      end
    end
    ui_fate.g_timer_second.suspended = true
    ui_fate.g_timer_enter.suspended = true
  end
end
function on_timer_tick_three_select_two()
end
function on_move_anime(index, new_control_index)
  local set_index = index
  local control_index = new_control_index
  local function on_time_set_data()
    if sys.check(ui_fate.w_main) ~= true then
      return
    end
    local rand_name = sys.format("random%d", set_index)
    local selected_list = ui_fate.w_main:search("selected_list")
    local rand_control = selected_list:search(rand_name)
    local new_name = sys.format("c%d", control_index)
    local npc_list = ui_fate.w_main:search("npc_list")
    new_control = npc_list:search(new_name)
    local new_portrait = new_control:search("portrait")
    local rand_portrait = rand_control:search("portrait")
    rand_portrait.image = new_portrait.image
    rand_portrait.effect = ""
    rand_control.visible = true
    rand_control.tip.text = new_control.tip.text
    new_portrait.effect = "gray"
    rand_portrait.var:set(packet.key.cha_id, new_portrait.var:get(packet.key.cha_id))
  end
  if ui_fate.w_main.visible ~= true then
    on_time_set_data()
    return
  end
  bo2.PlaySound2D(ui_champion.g_sound_mover)
  ui_qbar.ui_hide_anim.w_hide_anim:frame_clear()
  ui_qbar.ui_hide_anim.w_hide_anim.visible = true
  local rand_name = sys.format("c%d", control_index)
  local selected_list = ui_fate.w_main:search("npc_list")
  local rand_control = selected_list:search(rand_name)
  local rand_portait = rand_control:search("portrait")
  local w_move_target = rand_portait
  local w_move_pos_name = sys.format("random%d", set_index)
  local npc_list = ui_fate.w_main:search("selected_list")
  local pos_data = npc_list:search(w_move_pos_name)
  pos_data.visible = true
  local w_move_pos = pos_data:search("portrait")
  w_move_pos.image = nil
  local f = ui_qbar.ui_hide_anim.w_hide_anim:frame_insert(1000, w_move_target)
  local bs = w_move_target.size
  local ws = w_move_pos.size
  local pos = w_move_pos:control_to_window(ui.point(0, 0)) + bs * 0.5
  local src = w_move_pos.offset + ws * 0.5
  local dis = pos - src
  local dis1 = w_move_target:control_to_window(ui.point(0, 0))
  f:set_translate1(dis1.x, dis1.y)
  f:set_translate2(dis.x, dis.y)
  bo2.AddTimeEvent(25, on_time_set_data)
end
function on_timer_random_19()
  if g_first_node == 0 then
    g_index = g_index + 1
    if g_index > 19 then
      g_index = 0
    end
    g_index_2p = g_index_2p - 1
    if 0 > g_index_2p then
      g_index_2p = 19
    end
    while g_select_table[g_index] ~= nil do
      g_index = g_index + 1
      if g_index > 19 then
        g_index = 0
      end
    end
    repeat
      while g_select_table[g_index_2p] ~= nil do
        g_index_2p = g_index_2p - 1
        g_index_2p = 19
      end
    until 0 > g_index_2p
  else
    g_index = g_index - 1
    if 0 > g_index then
      g_index = 19
    end
    g_index_2p = g_index_2p + 1
    if 19 < g_index_2p then
      g_index_2p = 0
    end
    while g_select_table[g_index] ~= nil do
      g_index = g_index - 1
      if 0 > g_index then
        g_index = 19
      end
    end
    while g_select_table[g_index_2p] ~= nil do
      g_index_2p = g_index_2p + 1
      if 19 < g_index_2p then
        g_index_2p = 0
      end
    end
  end
  local new_control
  local compare_index = g_selected_data_count
  local bFind = false
  for i = 0, 1 do
    local new_name
    if i == 0 then
      if g_selected_data_count == 0 then
        new_name = sys.format("c%d", g_index)
      end
    else
      new_name = sys.format("c%d", g_index_2p)
    end
    local npc_list = ui_fate.w_main:search("npc_list")
    local _control = npc_list:search(new_name)
    if sys.check(_control) then
      _control:search("highlight_select").visible = true
    end
  end
  local new_control_index = 0
  if g_count_table[compare_index] ~= nil and g_tick_times <= g_count_table[compare_index] then
    if g_selected_data_count == 0 then
      if g_index == g_server_select_index[g_selected_data_count] then
        bFind = true
        new_control_index = g_index
      end
    elseif g_index_2p == g_server_select_index[g_selected_data_count] then
      bFind = true
      new_control_index = g_index_2p
    end
  end
  if bFind then
    g_select_table[g_index] = g_index
    g_count_table[compare_index] = nil
    on_move_anime(g_selected_data_count, new_control_index)
    g_selected_data_count = g_selected_data_count + 1
  end
  if g_selected_data_count >= 2 then
    local function on_init_three_select_one_data()
      g_tick_times = g_anime_tick
      g_random_state = cRandomState_Anime
    end
    on_init_three_select_one_data()
  end
  if ui_fate.w_main.visible == true then
    bo2.PlaySound2D(608)
  end
  g_tick_times = g_tick_times - 1
end
function on_timer_set_random_data()
  local champion_time = ui_fate.w_main:search("fate_time")
  local w_champion_time_0 = champion_time:search("time0")
  local w_champion_time_1 = champion_time:search("time1")
  champion_time.visible = true
  w_champion_time_0.visible = true
  w_champion_time_1.visible = true
  for i = 0, g_ci_max_portrait_size do
    local old_name = sys.format("c%d", i)
    local npc_list = ui_fate.w_main:search("npc_list")
    local old_control = npc_list:search(old_name)
    if sys.check(old_control) then
      old_control:search("highlight_select").visible = false
    end
  end
  for i = 0, 1 do
    local rand_old_name = sys.format("random%d", i)
    local selected_list = ui_fate.w_main:search("selected_list")
    local rand_old_control = selected_list:search(rand_old_name)
    if sys.check(rand_old_control) then
      rand_old_control:search("highlight_select").visible = false
    end
  end
  if g_timer_count >= 0 and g_timer_count % 10 == 0 then
    local iCurrentSecond = g_timer_count / 10
    local iSecond0 = math.floor(g_timer_count / 100)
    local iSecond1 = math.fmod(iCurrentSecond, 10)
    local get_time_pos_data = function(iSecond)
      return sys.format("$image/champion/new_num/%d.png", iSecond)
    end
    w_champion_time_0.image = get_time_pos_data(iSecond0)
    w_champion_time_1.image = get_time_pos_data(iSecond1)
  end
  if g_random_state == cRandomState_R19 then
    on_timer_random_19()
  elseif g_random_state == cRandomState_R3 then
    on_timer_anime()
  elseif g_random_state == cRandomState_Anime then
    on_timer_anime()
  else
    ui_fate.g_timer_second.suspended = true
  end
  g_timer_count = g_timer_count - 1
end
function begin_random_npc(iSelect)
  ui_fate.g_timer_second.suspended = false
  if ui_fate.g_timer_second.suspended == false then
    local iServerSelectNpc = {}
    for i, v in pairs(iSelect) do
      local excel_npc = bo2.gv_cavalier_championship_npc:find(v)
      if sys.check(excel_npc) then
        iServerSelectNpc[i] = excel_npc.in_pos[g_team_data.act - 1]
      end
    end
    on_begin_random_data(iServerSelectNpc)
  end
end
function stop_test()
  g_timer_enter.suspended = true
end
function on_challenger_anime()
  if ui_fate.w_main.visible ~= true then
    return
  end
  local rand_name = sys.format("random1")
  local selected_list = ui_fate.w_main:search("selected_list")
  local rand_control = selected_list:search(rand_name)
  local new_portrait = rand_control:search("portrait")
  ui_qbar.ui_hide_anim.w_hide_anim:frame_clear()
  ui_qbar.ui_hide_anim.w_hide_anim.visible = true
  local w_move_target = new_portrait
  local w_move_pos_name = sys.format("r%d", g_team_data.act - 1)
  local act_list = ui_fate.w_main:search("act_list")
  local w_move_pos = act_list:search(w_move_pos_name):search("portrait")
  local f = ui_qbar.ui_hide_anim.w_hide_anim:frame_insert(1000, w_move_target)
  local bs = w_move_target.size
  local ws = w_move_pos.size
  local pos = w_move_pos:control_to_window(ui.point(0, 0)) + bs * 0.5
  local src = w_move_pos.offset + ws * 0.5
  local dis = pos - src
  local dis1 = w_move_target:control_to_window(ui.point(0, 0))
  f:set_translate1(dis1.x, dis1.y)
  f:set_translate2(dis.x, dis.y)
  local function set_portrait_data()
    local new_name = sys.format("random%d", 1)
    local selected_list = ui_fate.w_main:search("selected_list")
    local new_control = selected_list:search(new_name)
    local new_portrait = new_control:search("portrait")
    local act_name = sys.format("r%d", g_team_data.act - 1)
    local act_list = ui_fate.w_main:search("act_list")
    local act_control = act_list:search(act_name)
    local act_portrait = act_control:search("portrait")
    act_portrait.visible = true
    act_portrait.image = new_portrait.image
  end
  bo2.AddTimeEvent(25, set_portrait_data)
end
function run_test_match()
  local v = sys.variant()
  v:set(packet.key.fate_master, 1001)
  v:set(packet.key.fate_servant, 1002)
  on_handle_fate_player_match(1, v)
end
function on_handle_fate_player_match(cmd, data)
  ui_fate.g_timer_second.suspended = true
  ui_fate.g_timer_enter.suspended = true
  local champion_time = ui_fate.w_main:search("fate_time")
  local w_champion_time_0 = champion_time:search("time0")
  local w_champion_time_1 = champion_time:search("time1")
  w_champion_time_0.visible = false
  w_champion_time_1.visible = false
  for i = 0, 19 do
    local old_name = sys.format("c%d", i)
    local npc_list = ui_fate.w_main:search("npc_list")
    local old_control = npc_list:search(old_name)
    if sys.check(old_control) then
      old_control:search("portrait").effect = "gray"
      old_control:search("highlight_select").visible = false
    end
  end
  local v_portait = {}
  v_portait[0] = data:get(packet.key.fate_master).v_int
  v_portait[1] = data:get(packet.key.fate_servant).v_int
  for i = 0, 1 do
    local rand_old_name = sys.format("random%d", i)
    local selected_list = ui_fate.w_main:search("selected_list")
    local rand_old_control = selected_list:search(rand_old_name)
    if sys.check(rand_old_control) then
      rand_old_control.visible = true
      local rand_portrait = rand_old_control:search("portrait")
      rand_portrait.image = on_get_portrait_icon(v_portait[i])
    end
  end
  local new_challenger = ui_fate.w_main:search("new_challenger")
  new_challenger.visible = true
  on_challenger_anime()
end
function on_handle_fate_auto_group(cmd, data)
  bo2.send_variant(packet.eCTS_Group_AddRequest, data)
end
ui_packet.recv_wrap_signal_insert(packet.eSTC_Fate_AutoGroupData, on_handle_fate_auto_group, "ui_fate::on_handle_fate_auto_group")
ui_packet.recv_wrap_signal_insert(packet.eSTC_Fate_PlayerMatchData, on_handle_fate_player_match, "ui_fate::on_handle_fate_player_match")
