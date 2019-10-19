local reg = ui_packet.game_recv_signal_insert
local sig = "ui_deathui.packet_handle"
local death_countdown = 10
local COUNT_MAX = 10
local cur_parent_name
local g_death_data = {}
local g_knight_data = {}
local g_cloned_battle_death_countdown = 0
local g_no_close_ui = false
local g_has_result = false
local g_send_cloned_battle_msg = true
function on_click_deathui_countdown(ctrl)
end
local SetDeathUIText = function(control, time, text_format)
  local param = sys.variant()
  if time > 60 then
    local iHour = math.floor(time / 3600)
    local v = math.fmod(time, 3600)
    local iMinute = math.floor(v / 60)
    local iSecond = math.fmod(v, 60)
    local param = sys.variant()
    param:set("minute", iMinute)
    param:set("second", iSecond)
    local fmt = ui.get_text("common|death_minute_second")
    local wstr_text = sys.mtf_merge(param, fmt)
    param:set("leave_time", wstr_text)
  else
    param:set("leave_time", time)
  end
  control.mtf = sys.mtf_merge(param, text_format)
end
function on_deathui_countdown(timer)
end
function reset_count_ui()
  death_countdown = COUNT_MAX
end
function on_knight_deathui_countdown(timer)
  local w_knight_deathcountd = ui_deathui.knight_deathcountd_add
  if sys.check(w_knight_deathcountd) ~= true then
    timer.suspended = true
    return
  end
  death_countdown = death_countdown - 1
  if sys.check(g_knight_data) and sys.check(g_knight_data.countd_mtf) then
    SetDeathUIText(w_knight_deathcountd, death_countdown, g_knight_data.countd_mtf)
  end
  if death_countdown <= 0 then
    timer.suspended = true
    if g_no_close_ui == false then
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_deathCount_Knight_ReplyAsk, v)
    end
    ui_deathui.g_knight_over_countd.visible = false
  end
end
function on_click_deathui_countdown_knight(ctrl)
  local on_check_death = function()
    local player = bo2.player
    if sys.check(player) and player:IsDead() ~= true then
      return true
    end
    return false
  end
  local function on_call_back_close(msg)
    if sys.check(msg) and msg.result == 0 then
      return true
    end
    local scn = bo2.scn
    if g_has_result == false and sys.check(scn) and sys.check(scn.excel) and scn.excel.id >= 310 and scn.excel.id < 330 and on_check_death() == true then
      g_no_close_ui = false
      ui_deathui.g_knight_over_countd.visible = false
      return true
    end
    g_no_close_ui = false
    g_timer_knight_over.suspended = true
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_deathCount_Knight_ReplyAsk, v)
    if g_knight_over_countd.visible == true then
      g_knight_over_countd.visible = false
    end
  end
  if g_no_close_ui == true then
    if on_check_death() == true then
      g_no_close_ui = false
      ui_deathui.g_knight_over_countd.visible = false
      return true
    end
    local msg = {
      callback = on_call_back_close,
      text = ui.get_text("fate|fate_leave_scene")
    }
    ui_widget.ui_msg_box.show_common(msg)
  else
    on_call_back_close()
  end
end
function on_knight_dlg_init()
  local richbox_panel = g_knight_over_countd:search("richbox_panel")
  richbox_panel.dy = g_knight_over_countd.dy - 80
end
function on_esc_close_cb(w, vis)
  if vis ~= true then
    on_click_deathui_countdown_cloned_battle()
  end
end
function on_esc_vis_knight_over_countdown(w, vis)
  if vis then
  elseif g_no_close_ui == true then
    w.visible = true
  end
end
function set_fate_wait(data, vis)
  g_cloned_battle_count_down.visible = vis
  if not vis then
    return
  end
  local v_data = {}
  death_countdown = data:get(packet.key.knight_pk_leave_time).v_int
  local stk_push_new_line = function(stk)
    stk:push("\n")
  end
  local stk = sys.stack()
  stk:push(ui.get_text("fate|fate_wait"))
  stk_push_new_line(stk)
  local iDeathPoint = data:get(packet.key.ranklist_id).v_int
  local show_death_point = iDeathPoint > 0 and ui_fate ~= nil and ui_fate.get_current_score() >= 5
  if data:has(packet.key.target_name) then
    show_death_point = true
  end
  if show_death_point then
    local _point = sys.format("<c+:ff0000>%d<c->", 5)
    stk:push(ui_widget.merge_mtf({score = _point}, ui.get_text("fate|fate_death_punish_point")))
    stk_push_new_line(stk)
  end
  stk:push(ui.get_text("fate|fate_death_leave"))
  stk_push_new_line(stk)
  local cb_data = {}
  cb_data.vis = true
  cb_data.count_down = death_countdown
  cb_data.msg = false
  cb_data.comment = false
  cb_data.text = stk.text
  cb_data.fadd = ui.get_text("common|knight_over_leave_inf")
  cb_data.fadd_plus = ui.get_text("common|death_minute_second")
  cb_data.dy = 340
  cb_data.p_dy = 215
  cb_data.pp_dy = 260
  visible_cb_count_down(cb_data)
end
function set_fate_result_info(data, vis)
  g_cloned_battle_count_down.visible = vis
  if not vis then
    return
  end
  local v_data = {}
  v_data.second, v_data.hp_lost, v_data.bisha_times = get_knight_pk_data()
  v_data.act = data:get(packet.key.fate_act).v_int
  v_data.scores = data:get(packet.key.fate_score).v_int
  v_data.add_scores = data:get(packet.key.player_view_skill_score).v_int
  if v_data.act > 100 then
    v_data.act = v_data.act - 100
  end
  local stk_push_new_line = function(stk)
    stk:push("\n")
  end
  local is_win = data:get(packet.key.cmn_rst).v_int
  local stk = sys.stack()
  if is_win == 1 then
    stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("fate|fate_win"))))
  elseif is_win == 0 then
    local _current_score = 0
    if ui_fate ~= nil then
      _current_score = ui_fate.get_current_score()
    end
    stk:push(ui_widget.merge_mtf({current_score = _current_score}, sys.format(ui.get_text("fate|fate_faild"))))
  end
  local award_excel_id = data:get(packet.key.ranklist_id).v_int
  local score_award_excel = bo2.gv_fate_score_award:find(award_excel_id)
  local eLevel = ui.safe_get_atb(bo2.eAtb_Level)
  if sys.check(score_award_excel) then
    if data:get(packet.key.has_award).v_int == 1 then
      v_data.next_score = score_award_excel.iMinScore
      stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("fate|fate_award_score"))))
      stk_push_new_line(stk)
      if 0 < score_award_excel.award_exp_persent then
        local _exp = score_award_excel.award_exp_persent * eLevel
        stk:push(ui_widget.merge_mtf({exp = _exp}, sys.format(ui.get_text("fate|fate_exp"))))
        stk_push_new_line(stk)
      end
      if 0 < score_award_excel.award_money_persent then
        local _money = score_award_excel.award_money_persent * eLevel
        local award_money
        if score_award_excel.award_money_type == 0 then
          award_money = sys.format("<m:%d>", _money)
        else
          award_money = sys.format("<bm:%d>", _money)
        end
        stk:push(ui_widget.merge_mtf({money = award_money}, sys.format(ui.get_text("fate|fate_money"))))
        stk_push_new_line(stk)
      end
      if 0 < score_award_excel.award_item_id then
        local _item = sys.format("<i:%d>", score_award_excel.award_item_id)
        stk:push(ui_widget.merge_mtf({
          item = _item,
          count = score_award_excel.award_item_count
        }, sys.format(ui.get_text("fate|fate_item"))))
        stk_push_new_line(stk)
      end
    else
      v_data.next_score = score_award_excel.iMinScore
      stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("fate|fate_next_score"))))
      stk_push_new_line(stk)
      if 0 < score_award_excel.award_exp_persent then
        local _exp = score_award_excel.award_exp_persent * eLevel
        local exp_text = sys.format("<c+:00FF00>%d<c->", _exp)
        stk:push(ui_widget.merge_mtf({exp = exp_text}, sys.format(ui.get_text("fate|fate_score_exp"))))
        stk_push_new_line(stk)
      end
      if 0 < score_award_excel.award_money_persent then
        local _money = score_award_excel.award_money_persent * eLevel
        local award_money
        if score_award_excel.award_money_type == 0 then
          award_money = sys.format("<m:%d>", _money)
        else
          award_money = sys.format("<bm:%d>", _money)
        end
        stk:push(ui_widget.merge_mtf({money = award_money}, sys.format(ui.get_text("fate|fate_score_money"))))
        stk_push_new_line(stk)
      end
      if 0 < score_award_excel.award_item_count then
        local _item = sys.format("<i:%d>", score_award_excel.award_item_id)
        stk:push(ui_widget.merge_mtf({
          item = _item,
          count = score_award_excel.award_item_count
        }, sys.format(ui.get_text("fate|fate_score_item"))))
        stk_push_new_line(stk)
      end
    end
  else
    stk:push(ui.get_text("fate|fate_full_award"))
    stk_push_new_line(stk)
  end
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("fate|fate_data"))))
  local cb_data = {}
  cb_data.vis = true
  cb_data.count_down = 10
  cb_data.msg = true
  cb_data.comment = false
  cb_data.text = stk.text
  cb_data.fadd = ui.get_text("common|knight_over_leave_inf")
  cb_data.dy = 340
  cb_data.p_dy = 215
  cb_data.pp_dy = 260
  visible_cb_count_down(cb_data)
end
function set_champion_result_info(data, vis)
  g_cloned_battle_count_down.visible = vis
  if not vis then
    return
  end
  local v_data = {}
  v_data.second, v_data.hp_lost, v_data.bisha_times = get_knight_pk_data()
  v_data.act = data:get(packet.key.dexp_id).v_int
  v_data.act_award = data:get(packet.key.dexp_hours).v_int
  local award_excel = bo2.gv_cavalier_championship_award:find(v_data.act_award)
  local iLevel = ui.safe_get_atb(bo2.eAtb_Level)
  if sys.check(award_excel) then
    v_data.exp = award_excel.award_exp_persent * iLevel + award_excel.award_base_exp
    local _money = award_excel.award_money_persent * iLevel + award_excel.award_base_money
    if v_data.act == 8 then
      v_data.money = sys.format(L("<m:%d>"), ui_champion.g_award_money + _money)
      v_data.exp = sys.format(L("%d"), ui_champion.g_award_exp + v_data.exp)
    else
      v_data.money = sys.format(L("<m:%d>"), _money)
    end
  end
  local is_win = data:get(packet.key.cmn_rst).v_int
  local td = {}
  if is_win == 1 then
    if v_data.act == 8 then
      td.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|champion_clear")))
    else
      ui_champion.g_open_champion = true
      td.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|champion_win")))
    end
  elseif is_win == 0 then
    if sys.check(ui_champion) then
      v_data.money = sys.format(L("<m:%d>"), ui_champion.g_award_money)
      v_data.exp = ui_champion.g_award_exp
      td.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|champion_faild")))
    end
  elseif is_win == 4 then
    if ui_champion.g_current_act == nil then
      v_data.act = 1
    else
      v_data.act = ui_champion.g_current_act
    end
    local act_excel = bo2.gv_cavalier_championship_act:find(v_data.act)
    v_data.act_award = act_excel.act_award
    if v_data.act == 8 then
      v_data.money = sys.format(L("<m:%d>"), ui_champion.g_award_money)
      v_data.exp = sys.format(L("%d"), ui_champion.g_award_exp)
      td.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|champion_faild")))
    else
      v_data.char_name = data:get(packet.key.target_name).v_string
      if sys.check(bo2.player) then
        local state_id = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_ChampionFaildStateIndex)
        local falid_state_excel = bo2.gv_cavalier_championship_faild_state:find(state_id)
        if sys.check(falid_state_excel) then
          local state_excel = bo2.gv_state_container:find(falid_state_excel.state_id)
          if sys.check(state_excel) then
            v_data.state_name = state_excel.name
          end
        end
      end
      ui_champion.g_open_champion = true
      td.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|champion_player_faild")))
    end
  elseif is_win == 3 then
    if ui_champion.g_current_act == nil then
      v_data.act = 1
    else
      v_data.act = ui_champion.g_current_act
    end
    local act_excel = bo2.gv_cavalier_championship_act:find(v_data.act)
    v_data.act_award = act_excel.act_award
    local award_excel = bo2.gv_cavalier_championship_award:find(v_data.act_award)
    v_data.add_rate = award_excel.award_player_act_min
    v_data.money = sys.format(L("<m:%d>"), ui_champion.g_award_money * v_data.add_rate)
    v_data.exp = sys.format(L("%d"), ui_champion.g_award_exp * v_data.add_rate)
    v_data.add_rate = sys.format("%.0f", v_data.add_rate * 100)
    v_data.char_name = data:get(packet.key.target_name).v_string
    if v_data.act == 8 then
      td.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|champion_clear")))
    else
      ui_champion.g_open_champion = true
      td.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|champion_player_win")))
    end
  end
  local cb_data = {}
  cb_data.vis = true
  cb_data.count_down = 10
  cb_data.msg = true
  cb_data.comment = false
  cb_data.text = td.mtf
  cb_data.fadd = ui.get_text("common|knight_over_leave_inf")
  cb_data.dy = 340
  cb_data.p_dy = 215
  cb_data.pp_dy = 260
  visible_cb_count_down(cb_data)
end
function set_knight_pk_info_visible(data, vis)
  g_knight_over_countd.visible = vis
  if not vis then
    return
  end
  local is_helper = data:has(packet.key.is_knight_helper)
  local fighter_name = data:get(packet.key.knight_pk_fighter_name).v_string
  local pk_time_use = data:get(packet.key.knight_pk_time_use).v_int
  local player_life_lose = data:get(packet.key.knight_pk_life_damage).v_int
  local pk_bisha_use_times = data:get(packet.key.knight_pk_bisha_use).v_int
  local pk_time_use = data:get(packet.key.knight_pk_time_use).v_int
  local knight_fight_id = data:get(packet.key.knight_pk_npc_cha_id).v_int
  local depth_value = data:get(packet.key.knight_pk_depth_value).v_int
  local current_depth = data:get(packet.key.knight_pk_current_depth_value).v_int
  local npc_lvl = data:get(packet.key.knight_pk_npc_lvl).v_int
  local iIncreaseExp = data:get(packet.key.knight_pk_exp).v_int
  local iIncreaseVipExp = data:get(packet.key.knight_pk_privilege_exp).v_int
  local renown_add = data:get(packet.key.knight_pk_renown_add).v_int
  local repute_add = data:get(packet.key.knight_pk_repute_add).v_int
  local count_down = data:get(packet.key.knight_pk_leave_time).v_int
  local repute_name = data:get(packet.key.knight_pk_repute_name).v_string
  local errantry_count = data:get(packet.key.errantry_count).v_int
  local qxh_remain_num = data:get(packet.key.qxh_npc_number).v_int
  local knight_pk_type = data:get(packet.key.knight_pk_type).v_int
  local fight_times = data:get(packet.key.knight_pk_fight_times).v_int
  local param = sys.variant()
  param:set("exp_count", iIncreaseExp)
  param:set("exp_vip_count", iIncreaseVipExp)
  local use_minutes = math.floor(pk_time_use / 60)
  local use_seconds = pk_time_use - use_minutes * 60
  local use_time_str = use_seconds .. ui.get_text("common|second")
  if use_minutes > 0 then
    local use_hours = math.floor(use_minutes / 60)
    local use_minutes = use_minutes - use_hours * 60
    use_time_str = use_minutes .. ui.get_text("common|minute") .. use_time_str
    if use_hours > 0 then
      use_time_str = use_hours .. ui.get_text("common|hour") .. use_time_str
    end
  end
  param:set("fighter_name", fighter_name)
  param:set("using_time", use_time_str)
  param:set("lose_life", player_life_lose)
  param:set("bisha_times", pk_bisha_use_times)
  param:set("depth_value", depth_value)
  param:set("current_depth", current_depth)
  param:set("fight_times", fight_times)
  param:set("rep_name", repute_name)
  param:set("rep_value", repute_add)
  param:set("renown", renown_add)
  param:set("errantry", errantry_count)
  local _vp = 0
  if sys.check(bo2.player) then
    _vp = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
  end
  local vip = sys.format(L("<vip:%d,3,8>"), _vp)
  param:set("vip", vip)
  local npc_excel = bo2.gv_cha_list:find(knight_fight_id)
  if npc_excel == nil then
    ui.log("KNIGHT_FIGHT:NPC name error")
  else
    local npc_name = npc_excel.name
    param:set("npc_name", npc_name)
    if data:has(packet.key.knight_pk_type) then
    else
      param:set("knight_name", npc_name)
    end
  end
  local fmt = ""
  if not is_helper then
    fmt = fmt .. ui.get_text("common|knight_over_exp")
  end
  if data:has(packet.key.knight_pk_items) then
    local item_data = data:get(packet.key.knight_pk_items).v_int
    if item_data ~= nil then
      fmt = fmt .. ui.get_text("common|knight_over_item")
      param:set("item", item_data)
    end
  end
  if knight_pk_type == 1 then
    fmt = fmt .. ui.get_text("common|knight_over_other_inf_qxh")
  elseif is_helper then
    fmt = fmt .. ui.get_text("common|knight_over_other_inf_helper")
  else
    fmt = fmt .. ui.get_text("common|knight_over_other_inf")
  end
  local is_win = data:get(packet.key.cmn_rst).v_int
  if knight_pk_type == 1 then
    npc_lvl = npc_lvl + 1
    if is_win == bo2.eMatchResult_Win then
      fmt = fmt .. ui.get_text("common|qxh_remain_knight")
      param:set("remain_knight", qxh_remain_num)
    end
    if is_win == bo2.eMatchResult_Lose or qxh_remain_num == 0 then
      fmt = fmt .. ui.get_text("common|qxh_over_remark_inf")
    end
    knight_info_btn.visible = false
  else
    local player_lvl = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_KnightPKInLvl)
    npc_lvl = math.floor(player_lvl / 10)
    data:set(packet.key.knight_pk_npc_lvl, npc_lvl)
    if not is_helper then
      fmt = fmt .. ui.get_text("common|knight_over_remark_inf")
    end
    knight_info_btn.visible = true
  end
  if is_win == bo2.eMatchResult_Win then
    fmt = ui.get_text("common|knight_over_win") .. fmt
    param:set("npc_lvl", npc_lvl)
  else
    fmt = ui.get_text("common|knight_over_lose") .. fmt
    local title_excel = bo2.gv_title_list:find(npc_excel.title_id)
    if title_excel == nil then
      ui.log("KNIGHT_FIGHT:NPC title error")
    else
      local title_name = "\\<" .. title_excel._name .. ">"
      param:set("npc_title", title_name)
    end
  end
  local event_mgr = ui_rand_event.g_event_mgr
  if nil ~= event_mgr then
    local event = event_mgr.event
    fmt = fmt .. [[


]]
    for i, v in pairs(event) do
      local _, bsucc, _ = ui_rand_event.GetStateDetail(v.state)
      if bsucc then
        fmt = fmt .. ui.get_text("common|knight_rand_event" .. v.idx)
        param:set("event" .. v.idx, v.short_desc)
        local money = v.money_base + v.money_level
        local exp = v.exp_base + v.exp_level
        if 0 ~= money then
          fmt = fmt .. ui.get_text("common|knight_event_money" .. v.idx)
          if 0 == v.money_type then
            param:set("event_money" .. v.idx, sys.format("<m:%d>", money))
          else
            param:set("event_money" .. v.idx, sys.format("<bm:%d>", money))
          end
        end
        if 0 ~= exp then
          fmt = fmt .. ui.get_text("common|knight_event_exp" .. v.idx)
          param:set("event_exp" .. v.idx, exp)
        end
      end
    end
  end
  local str = sys.mtf_merge(param, fmt)
  local death_countd = g_knight_over_countd:search("deathcountd")
  knight_deathcountd.mtf = str
  g_timer_knight_over.suspended = not vis
end
function on_closeUI(cmd, data)
  g_no_close_ui = false
  if data:has(packet.key.fight_with_knight_over) then
    ui_knight.w_seekhelp_button.enable = false
    ui_knight.w_seekhelp_flash.visible = false
    local info_data = data
    local pk_time_use, player_life_lose, pk_bisha_use_times = get_knight_pk_data()
    info_data:set(packet.key.knight_pk_life_damage, player_life_lose)
    info_data:set(packet.key.knight_pk_time_use, pk_time_use)
    info_data:set(packet.key.knight_pk_bisha_use, pk_bisha_use_times)
    info_data:set(packet.key.knight_pk_fighter_name, ui.get_text("common|congrats"))
    local is_win = data:get(packet.key.cmn_rst).v_int
    if is_win == bo2.eMatchResult_Win then
    elseif knight_list ~= nil then
      for i = 0, knight_list.size - 1 do
        local knight = knight_list:get(i)
        local handle = knight:get(packet.key.scnobj_handle).v_string
        local pKnight = bo2.findobj(handle)
        if pKnight ~= nil then
          pKnight:playsound(bo2.eSE_Knight_ContestWin)
        end
      end
    end
    ui_knight.knight_pk_over(knight_fight_id)
    set_knight_pk_info_visible(info_data, true)
    info_data:set(packet.key.knight_pk_fighter_name, bo2.player.name)
    local count_down = data:get(packet.key.knight_pk_leave_time).v_int
    death_countdown = count_down
    local knight_pk_type = data:get(packet.key.knight_pk_type).v_int
    local fmt_add = ui.get_text("common|knight_over_leave_inf")
    if knight_pk_type == 1 then
      knight_deathcountd_add.visible = false
    else
      knight_deathcountd_add.visible = true
    end
    local param_add = sys.variant()
    param_add:set("leave_time", death_countdown)
    local str_add = sys.mtf_merge(param_add, fmt_add)
    knight_deathcountd_add.mtf = str_add
    g_knight_data.countd_mtf = fmt_add
    bo2.send_variant(packet.eCTS_Knight_PK_Info, info_data)
    local rst_state_id = data:get(packet.key.marquee_type).v_int
    local rst_name = data:get(packet.key.target_masked_name).v_string
    if rst_state_id ~= 0 then
      switch_knight_comment(true)
      local rst_state_excel = bo2.gv_state_container:find(rst_state_id)
      if rst_state_excel ~= nil then
        local param = sys.variant()
        param:set("player_name", rst_name)
        param:set("state_name", rst_state_excel.name)
        local fmt = ui.get_text("common|death_add_state")
        local str = sys.mtf_merge(param, fmt)
        knight_state_comment_title.mtf = str
      end
      if is_win == bo2.eMatchResult_Win then
        btn_knight_comment_flower.check = true
        btn_knight_comment_bad_egg.check = false
      else
        btn_knight_comment_flower.check = false
        btn_knight_comment_bad_egg.check = true
      end
    else
      switch_knight_comment(false)
    end
    local is_helper = data:has(packet.key.is_knight_helper)
    if not is_helper then
      ui_gift_knight.update_count(is_win)
    end
  elseif data:has(packet.key.ui_death_count_down) then
    local count_down = data:get(packet.key.ui_death_count_down).v_int
    death_countdown = count_down
    local param = sys.variant()
    param:set("leave_time", death_countdown)
    local fmt = ui.get_text("common|death_leave_countdown")
    local str = sys.mtf_merge(param, fmt)
    deathcountd.mtf = str
    g_deathui_countd.visible = true
    g_timer_countdown.suspended = false
    g_death_data.countd_mtf = fmt
  elseif data:has(packet.key.cmn_type) then
    set_cloned_battle_result_info(data, true)
  elseif data:has(packet.key.group_union_id) then
    set_champion_result_info(data, true)
  elseif data:has(packet.key.fate_act) then
    set_fate_result_info(data, true)
  elseif data:has(packet.key.fate_first_time_check) then
    set_fate_wait(data, true)
  elseif data:has(packet.key.fate_npc_master) then
    set_cloned_battle_quickly_challenge_result_info(data, true)
  elseif data:has(packet.key.action_anim) then
    set_cross_line_result_info(data, true)
  elseif data:has(packet.key.org_listdata) then
    set_warrior_arena_result_info(data, true)
  elseif data:has(packet.key.player_tag) then
    set_warrior_arena_chaos(data, true)
  end
  ui_popo.del_popo_by_name("death_ui")
  local ui_visible = get_visible()
  if ui_visible == true then
    set_visible(false)
  end
end
function run_cl()
  local data = sys.variant()
  data:set(packet.key.cmn_rst, 1)
  data:set(packet.key.action_anim, 1)
  data:set(packet.key.knight_pk_fighter_name, L("123"))
  data:set(packet.key.gs_score, 100000)
  data:set(packet.key.fate_servant_score, 10)
  on_closeUI(1, data)
end
function run_q_cb()
  local data = sys.variant()
  data:set(packet.key.fate_npc_master, 1)
  data:set(packet.key.ranklist_id, 100)
  data:set(packet.key.target_name, L("123"))
  on_closeUI(1, data)
end
function run_cw()
  local data = sys.variant()
  data:set(packet.key.fate_first_time_check, 1)
  data:set(packet.key.target_name, 5)
  data:set(packet.key.knight_pk_leave_time, 1000)
  ui_champion.g_current_act = 1
  on_closeUI(1, data)
end
function run_ch()
  local data = sys.variant()
  data:set(packet.key.group_union_id, 1)
  data:set(packet.key.cmn_rst, 0)
  ui_champion.g_current_act = 1
  on_closeUI(1, data)
end
function run_test()
  local data = sys.variant()
  data:set(packet.key.cmn_type, 1)
  data:set(packet.key.fate_score, 650)
  data:set(packet.key.cmn_rst, 0)
  data:set(packet.key.ranklist_id, 0)
  data:set(packet.key.has_award, 0)
  data:set(packet.key.knight_pk_leave_time, 10)
  data:set(packet.key.marquee_type, 1)
  on_closeUI(1, data)
end
function run_test_data(score, rank_id)
  local data = sys.variant()
  data:set(packet.key.fate_act, 8)
  data:set(packet.key.fate_score, score.v_int)
  data:set(packet.key.player_view_skill_score, 100)
  data:set(packet.key.cmn_rst, 1)
  data:set(packet.key.ranklist_id, rank_id.v_int)
  on_closeUI(1, data)
end
function knight_close_over_UI(cmd, data)
  g_no_close_ui = false
  g_knight_over_countd.visible = false
  g_timer_knight_over.suspended = true
end
local g_fmt_text, g_fmt_text_plus
function on_cloned_battle_deathui_countdown()
  local death_countd = ui_deathui.cloned_battle_deathcountd_add
  g_cloned_battle_death_countdown = g_cloned_battle_death_countdown - 1
  local param = sys.variant()
  local fmt = g_fmt_text
  if fmt == nil then
    g_fmt_text = ui.get_text("common|knight_over_leave_inf")
    fmt = g_fmt_text
  end
  if g_fmt_text_plus ~= nil and g_cloned_battle_death_countdown > 60 then
    local death_countdown = g_cloned_battle_death_countdown
    local iHour = math.floor(death_countdown / 3600)
    local v = math.fmod(death_countdown, 3600)
    local iMinute = math.floor(v / 60)
    local iSecond = math.fmod(v, 60)
    param:set("minute", iMinute)
    param:set("second", iSecond)
    local wstr_text = sys.mtf_merge(param, g_fmt_text_plus)
    param:set("leave_time", wstr_text)
  else
    param:set("leave_time", g_cloned_battle_death_countdown)
  end
  death_countd.mtf = sys.mtf_merge(param, fmt)
  if g_cloned_battle_death_countdown <= 0 then
    g_timer_cloned_battle_over.suspended = true
    if g_cloned_battle_count_down.visible == true and g_send_cloned_battle_msg == true then
      local v = sys.variant()
      bo2.send_variant(packet.eCTS_deathCount_Knight_ReplyAsk, v)
    end
    g_cloned_battle_count_down.visible = false
  end
end
function switch_cloned_battle_comment(vis, title_text)
  if vis == true then
    g_panel_comment.visible = true
    ui_deathui.cloned_battle_info_btn.visible = false
    ui_deathui.g_cloned_battle_count_down.dy = 420
  else
    g_panel_comment.visible = false
    ui_deathui.cloned_battle_info_btn.visible = true
    ui_deathui.g_cloned_battle_count_down.dy = 320
  end
  local lb_title = g_cloned_battle_count_down:search("lb_title")
  if sys.check(lb_title) then
    if sys.check(title_text) then
      lb_title.text = title_text
    else
      lb_title.text = ui.get_text("common|countdown_title")
    end
  end
end
function on_click_deathui_comment(btn)
  switch_cloned_battle_comment(false)
  local v = sys.variant()
  if btn_comment_flower.check ~= false then
    v:set(packet.key.cmn_rst, 1)
  end
  bo2.send_variant(packet.eCTS_UI_ClonedBattle_CommentState, v)
end
function switch_knight_comment(vis)
  if vis == true then
    knight_panel_comment.visible = true
    ui_deathui.knight_info_btn.visible = false
    ui_deathui.g_knight_over_countd.dy = 570
  else
    knight_panel_comment.visible = false
    ui_deathui.knight_info_btn.visible = true
    ui_deathui.g_knight_over_countd.dy = 470
  end
end
function on_click_knight_deathui_comment(btn)
  switch_knight_comment(false)
  local v = sys.variant()
  if btn_knight_comment_flower.check ~= false then
    v:set(packet.key.cmn_rst, 1)
  end
  v:set(packet.key.is_knight_fight, 1)
  bo2.send_variant(packet.eCTS_UI_ClonedBattle_CommentState, v)
end
function on_click_deathui_countdown_cloned_battle(ctrl)
  g_timer_cloned_battle_over.suspended = true
  g_cloned_battle_count_down.visible = false
  if g_send_cloned_battle_msg == true then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_deathCount_Knight_ReplyAsk, v)
  end
end
local on_get_award_Data = function(rank_id, win)
  local nSize = bo2.gv_cloned_battle_single_challenge_award.size
  local pExcel
  for i = 0, nSize - 1 do
    pExcel = bo2.gv_cloned_battle_single_challenge_award:get(i)
    if 0 > pExcel.cur_level or rank_id <= pExcel.cur_level then
      if win == 1 then
        local _item = sys.format(L("<i:%d> x 1"), pExcel.award_item_index)
        local _exp = pExcel.win_award_money + ui.safe_get_atb(bo2.eAtb_Level) * pExcel.win_award_exp_per
        return _exp, pExcel.win_award_repute, _item
      else
        local _exp = pExcel.fail_award_money + ui.safe_get_atb(bo2.eAtb_Level) * pExcel.fail_award_exp_per
        return _exp, pExcel.fail_award_repute
      end
    end
  end
end
function run_wa()
  local data = sys.variant()
  data:set(packet.key.knight_pk_leave_time, 10)
  data:set(packet.key.org_listdata, 1)
  data:set(packet.key.cmn_rst, 0)
  data:set(packet.key.camp_id, 72101)
  data:set(packet.key.itemdata_val, L("hhy04"))
  data:set(packet.key.pet_breed_1, 100)
  on_closeUI(1, data)
end
function set_warrior_arena_result_info(data, vis)
  g_cloned_battle_count_down.visible = vis
  if not vis then
    return
  end
  local v_data = {}
  v_data.second, v_data.hp_lost, v_data.bisha_times = get_knight_pk_data()
  v_data.act = ui_warrior_arena.get_act()
  local is_win = data:get(packet.key.cmn_rst).v_int
  local stk = sys.stack()
  local stk_push_new_line = function(stk)
    stk:push("\n")
  end
  local rst = is_win
  local award_idx = data:get(packet.key.camp_id).v_int
  local mb_excel = bo2.gv_cavalier_championship_npc:find(award_idx)
  if sys.check(mb_excel) ~= true then
    v_data.char_name = data:get(packet.key.target_name).v_string
  else
    local cha_list = bo2.gv_cha_list:find(mb_excel.cha_list_id)
    if sys.check(cha_list) then
      v_data.char_name = cha_list.name
    end
  end
  g_cloned_battle_death_countdown = data:get(packet.key.knight_pk_leave_time).v_int
  if data:has(packet.key.itemdata_val) then
    v_data.char_name = data:get(packet.key.itemdata_val).v_string
    if is_win ~= 0 then
      stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|chaos_win"))))
    else
      stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|chaos_lost"))))
    end
  elseif is_win ~= 0 then
    stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|win_rst_title"))))
  else
    stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|lost_rst_title"))))
  end
  stk_push_new_line(stk)
  local xinshou_excel
  local idx_award = 0
  if data:has(packet.key.pet_breed_1) then
    idx_award = data:get(packet.key.pet_breed_1).v_int
  elseif sys.check(mb_excel) then
    idx_award = mb_excel.award_index
  end
  if data:has(packet.key.itemdata_val) then
    idx_award = 2000
  end
  if idx_award > 0 then
    local iLevel = ui.safe_get_atb(bo2.eAtb_Level)
    local iLevelBegin = 0
    local iLevelRange = 100
    if rst == 0 then
      iLevelBegin = 100
      iLevelRange = iLevelRange + iLevelBegin
    end
    for i = iLevelBegin, iLevelRange - 1 do
      local idx = idx_award + i
      xinshou_excel = bo2.gv_xinshou_campaign_award:find(idx)
      if xinshou_excel == nil then
        break
      end
      if xinshou_excel.award_type ~= rst then
        xinshou_excel = nil
        break
      end
      if iLevel >= xinshou_excel.level_begin and iLevel <= xinshou_excel.level_end then
        break
      end
    end
  end
  if sys.check(xinshou_excel) then
    if 0 < xinshou_excel.award_money then
      if xinshou_excel.award_money_type == 0 then
        v_data.award_money = sys.format("<m:%d>", xinshou_excel.award_money)
      else
        v_data.award_money = sys.format("<bm:%d>", xinshou_excel.award_money)
      end
      stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|award_money"))))
      stk_push_new_line(stk)
    end
    if 0 < xinshou_excel.award_exp then
      v_data.award_exp = xinshou_excel.award_exp
      stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|award_exp"))))
      stk_push_new_line(stk)
    end
    if 0 < xinshou_excel.award_score then
      stk:push("<c:9C9C9C>")
      v_data.award_score = xinshou_excel.award_score
      stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|award_score"))))
      stk_push_new_line(stk)
    end
  end
  stk:push("<c:9C9C9C>")
  v_data.score = sys.format(L("<c+:17A6DB>%d<c->"), bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_XinshouScore))
  stk:push(ui_widget.merge_mtf(v_data, ui.get_text("warrior_arena|self_score")))
  stk_push_new_line(stk)
  v_data.today_token = sys.format(L("<c+:17A6DB>%d<c->"), bo2.get_cd_real_token(50082))
  v_data.week_token = sys.format(L("<c+:17A6DB>%d<c->"), bo2.get_cd_real_token(50083))
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|today_token"))))
  stk_push_new_line(stk)
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|week_token"))))
  stk_push_new_line(stk)
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|common_desc"))))
  local cb_data = {}
  cb_data.vis = true
  cb_data.count_down = 10
  cb_data.msg = true
  cb_data.comment = false
  cb_data.text = stk.text
  cb_data.fadd = ui.get_text("common|knight_over_leave_inf")
  cb_data.dy = 340
  cb_data.p_dy = 215
  cb_data.pp_dy = 260
  visible_cb_count_down(cb_data)
end
function run_wac()
  local data = sys.variant()
  data:set(packet.key.knight_pk_leave_time, 5)
  data:set(packet.key.player_tag, 1)
  data:set(packet.key.knight_pk_fighter_name, L("123"))
  data:set(packet.key.cha_level, 10)
  on_closeUI(1, data)
end
function run_3()
  local m_data = sys.variant()
  m_data:set(packet.key.fate_missed_player_sideA, bo2.player.sel_handle)
  m_data:set(packet.key.item_key, 1)
  m_data:set(packet.key.item_key1, 0)
  m_data:set(packet.key.item_key2, 0)
  m_data:set(packet.key.item_key3, 0)
  m_data:set(packet.key.dooaltar_win, 10)
  m_data:set(packet.key.dooaltar_lost, 0)
  m_data:set(packet.key.pet_atb, 1)
  m_data:set(packet.key.cmn_money, 1000)
  m_data:set(packet.key.cmn_exp, 100)
  set_three_games_arena(m_data, true)
end
function set_three_games_arena(data, vis)
  g_cloned_battle_count_down.visible = vis
  if not vis then
    return
  end
  local stk_push_new_line = function(stk)
    stk:push("\n")
  end
  local stk = sys.stack()
  local cb_data = {}
  cb_data.vis = true
  local player_handle = 0
  if sys.check(bo2.player) then
    player_handle = bo2.player.sel_handle
  end
  local side = 2
  if player_handle == data:get(packet.key.fate_missed_player_sideA).v_int then
    side = 0
  elseif player_handle == data:get(packet.key.fate_missed_player_sideB).v_int then
    side = 1
  end
  local function push_fight_data()
    local end_text
    local count = 1
    local win_count = 0
    local lost_count = 0
    for i = packet.key.item_key, packet.key.item_key + 2 do
      if data:has(i) ~= true then
        break
      end
      local text = sys.format(L("match|fight%d"), count)
      count = count + 1
      stk:push(ui.get_text(text))
      local rst = data:get(i).v_int
      stk:push(L("<c+:FFFFFF>"))
      if rst < 0 then
        stk:push(ui.get_text(L("match|fight_tie_text")))
        end_text = ui.get_text(L("match|fight_tie1"))
      elseif rst == side then
        stk:push(ui.get_text(L("match|fight_win_text")))
        end_text = ui.get_text(L("match|fight_win1"))
      else
        stk:push(ui.get_text(L("match|fight_lost_text")))
        end_text = ui.get_text(L("match|fight_lost1"))
      end
      if data:has(packet.key.item_key1) then
        end_text = ui.get_text(L("match|next_win"))
      end
      stk:push(L("<c->"))
      stk_push_new_line(stk)
    end
    return end_text
  end
  local fadd
  local msg = false
  local comment = false
  local fight_type = data:get(packet.key.fight_npc_only_id).v_int
  if data:has(packet.key.dooaltar_win) ~= true then
    stk:push(L("<c:9C9C9C>"))
    if fight_type == bo2.eMatchType_ArenaSinglePractice then
      stk:push(ui.get_text("match|arena_desc_fight_practice"))
    else
      stk:push(ui.get_text("match|arena_desc_fight"))
    end
    stk_push_new_line(stk)
    local end_text = push_fight_data()
    if end_text ~= nil then
      stk:push(end_text)
      stk_push_new_line(stk)
    end
    cb_data.count_down = 5
    fadd = ui.get_text("match|fight_rst_inf")
  else
    local function process_arena()
      stk:push(L("<c:9C9C9C>"))
      local fight_rst = data:get(packet.key.item_key3).v_int
      if fight_rst >= 0 and fight_rst == side then
        stk:push(ui.get_text("match|win_title"))
      else
        stk:push(ui.get_text("match|lost_title"))
      end
      stk_push_new_line(stk)
      push_fight_data()
      local win_score = data:get(packet.key.dooaltar_win).v_int
      local lost_score = data:get(packet.key.dooaltar_lost).v_int
      local add_score = win_score + lost_score
      stk:push(ui.get_text("match|get_score"))
      stk:push(win_score)
      stk_push_new_line(stk)
      stk:push(ui.get_text("match|lost_score"))
      stk:push(lost_score)
      stk_push_new_line(stk)
      local current_score = 0
      stk:push(ui.get_text("match|get_total_score"))
      stk:push(add_score)
      stk_push_new_line(stk)
      local mtf = {}
      if sys.check(bo2.player) then
        current_score = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_ArenaRankScore)
        mtf.total_score = sys.format(L("<c+:17A6DB>%d<c->"), current_score)
        local excel = bo2.player:GetPlayerArenaRank()
        local get_excel_text = function(excel)
          local excel_text = bo2.gv_text:find(excel.desc_id)
          return excel_text.text
        end
        if excel then
          mtf.rank = sys.format(L("<c+:17A6DB>%s<c->"), get_excel_text(excel))
        end
        local next_excel = bo2.gv_arena_rank:find(excel.id + 1)
        stk:push(L("<c:FFFFFF>"))
        if next_excel ~= nil then
          mtf.rank_next = sys.format(L("<c+:17A6DB>%s<c->"), get_excel_text(next_excel))
          mtf.rank_next_score = next_excel.min_rank_score - current_score
          mtf.rank_next_score = sys.format(L("<c+:17A6DB>%d<c->"), mtf.rank_next_score)
          stk:push(ui_widget.merge_mtf(mtf, sys.format(ui.get_text("match|total_score"))))
          if excel.id < 17 then
            mtf.elo = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_ArenaElo_1V1_EncliseswinCount)
            if mtf.elo >= 3 then
              stk:push(ui_widget.merge_mtf(mtf, sys.format(ui.get_text("match|cur_e"))))
              stk:push(ui.get_text("match|get_e"))
            else
              stk:push(ui_widget.merge_mtf(mtf, sys.format(ui.get_text("match|cur_e"))))
              stk:push(ui.get_text("match|next_e"))
            end
          end
        else
          stk:push(ui_widget.merge_mtf(mtf, sys.format(ui.get_text("match|max_rank"))))
        end
      end
      cb_data.dy = 370
      cb_data.p_dy = 245
      cb_data.pp_dy = 290
      stk:push(L("<c:9C9C9C>"))
      stk:push(ui.get_text("match|award_exp"))
      local cmn_exp = data:get(packet.key.cmn_exp).v_int
      local cmn_money = data:get(packet.key.cmn_money).v_int
      stk:push(sys.format(L("<c+:17A6DB>%d<c->"), cmn_exp))
      stk_push_new_line(stk)
      stk:push(ui.get_text("match|award_money"))
      stk:push(sys.format(L("<c+:17A6DB><bm:%d><c->"), cmn_money))
      stk_push_new_line(stk)
      cb_data.count_down = 10
      fadd = ui.get_text("match|fight_end_inf")
      msg = true
    end
    local function process_practice()
      stk:push(L("<c:9C9C9C>"))
      local fight_rst = data:get(packet.key.item_key3).v_int
      local lost = false
      if fight_rst >= 0 and fight_rst == side then
        stk:push(ui.get_text("match|practice_win_title"))
      else
        stk:push(ui.get_text("match|lost_title"))
        lost = true
      end
      stk_push_new_line(stk)
      push_fight_data()
      if lost == true then
        if data:has(packet.key.pet_atb) then
          local v_comment = data:get(packet.key.pet_atb).v_int
          if v_comment == 1 then
            local mtf = {}
            mtf.p_count = bo2.gv_define:find(50016).value.v_int
            stk:push(ui_widget.merge_mtf(mtf, sys.format(ui.get_text("match|practice_flower"))))
          else
            stk:push(sys.format(ui.get_text("match|practice_egg")))
          end
          comment = false
          cb_data.count_down = 10
        else
          stk:push(ui.get_text("match|practice_lost_1"))
          stk_push_new_line(stk)
          stk:push(ui.get_text("match|practice_lost_2"))
          stk_push_new_line(stk)
          stk:push(ui.get_text("match|practice_lost_3"))
          stk_push_new_line(stk)
          comment = true
          cb_data.count_down = 60
          btn_comment_flower.check = true
          btn_comment_bad_egg.check = false
        end
      elseif data:has(packet.key.pet_atb) then
        local v_comment = data:get(packet.key.pet_atb).v_int
        if v_comment == 1 then
          local mtf = {}
          mtf.p_count = bo2.gv_define:find(50017).value.v_int
          stk:push(ui_widget.merge_mtf(mtf, sys.format(ui.get_text("match|practice_get_flower"))))
        else
          stk:push(sys.format(ui.get_text("match|practice_get_egg")))
        end
        comment = false
        cb_data.count_down = 10
      else
        stk:push(sys.format(ui.get_text("match|practice_win_wait")))
        stk_push_new_line(stk)
        comment = false
        cb_data.count_down = 60
      end
      fadd = ui.get_text("match|fight_end_inf")
      msg = true
    end
    if fight_type == bo2.eMatchType_ArenaSinglePractice then
      process_practice()
    else
      process_arena()
    end
  end
  cb_data.msg = msg
  cb_data.comment = comment
  cb_data.text = stk.text
  cb_data.fadd = fadd
  switch_cloned_battle_comment(comment, ui.get_text("match|fight_rst_title"))
  visible_cb_count_down(cb_data)
end
function set_warrior_arena_chaos(data, vis)
  g_cloned_battle_count_down.visible = vis
  if not vis then
    return
  end
  local v_data = {}
  local stk = sys.stack()
  local stk_push_new_line = function(stk)
    stk:push("\n")
  end
  stk:push(sys.format(ui.get_text("warrior_arena|chaos_describe")))
  v_data.cha_name = data:get(packet.key.cha_name).v_string
  v_data.level = data:get(packet.key.cha_level).v_int
  stk_push_new_line(stk)
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|chaos_name"))))
  stk_push_new_line(stk)
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("warrior_arena|chaos_level"))))
  local cb_data = {}
  cb_data.vis = true
  cb_data.count_down = 5
  cb_data.msg = false
  cb_data.comment = false
  cb_data.text = stk.text
  cb_data.fadd = ui.get_text("warrior_arena|chaos_inf")
  visible_cb_count_down(cb_data)
  switch_cloned_battle_comment(false, ui.get_text("warrior_arena|in_chaos_title"))
end
function set_cross_line_result_info(data, vis)
  g_cloned_battle_count_down.visible = vis
  if not vis then
    return
  end
  local v_data = {}
  v_data.cd = ui_cloned_battle.g_cloned_battle_challenge_token
  v_data.cha_name = data:get(packet.key.knight_pk_fighter_name).v_string
  v_data.gs_score = data:get(packet.key.gs_score).v_int
  v_data.second, v_data.hp_lost, v_data.bisha_times = get_knight_pk_data()
  local is_win = data:get(packet.key.cmn_rst).v_int
  if v_data.cha_name.size <= 1 then
    v_data.cha_name = ui.get_text("cross_line|default_fighter_name")
  end
  local stk = sys.stack()
  local stk_push_new_line = function(stk)
    stk:push("\n")
  end
  if is_win ~= 0 then
    stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|cross_line_win_title"))))
    stk_push_new_line(stk)
    local mb_data_size = bo2.gv_cross_line_single_award.size
    for i = 0, mb_data_size - 1 do
      local mb_excel = bo2.gv_cross_line_single_award:get(i)
      if sys.check(mb_excel) and (mb_excel.gs_score > v_data.gs_score or i + 1 > mb_data_size - 1) then
        if 0 < mb_excel.award_score then
          v_data.add_score = mb_excel.award_score
          stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|add_score"))))
          stk_push_new_line(stk)
          v_data.total_score = data:get(packet.key.fate_servant_score).v_int
          stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|total_score"))))
          stk_push_new_line(stk)
        end
        if 0 < mb_excel.award_exp then
          v_data.exp = mb_excel.award_exp
          stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|win_exp"))))
          stk_push_new_line(stk)
        end
        if 0 < mb_excel.award_money then
          if mb_excel.award_money_curreny ~= 1 then
            v_data.money = sys.format(L("<m:%d>"), mb_excel.award_money)
          else
            v_data.money = sys.format(L("<bm:%d>"), mb_excel.award_money)
          end
          stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|win_money"))))
          stk_push_new_line(stk)
        end
        if 0 < mb_excel.award_item.size then
          v_data.item = sys.format(L("<i:%d>"), mb_excel.award_item[0])
          v_data.count = mb_excel.award_item_count[0]
          stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|win_item"))))
          stk_push_new_line(stk)
        end
        break
      end
    end
  else
    if v_data.gs_score <= 0 then
      v_data.gs_score = ui.get_text("cross_line|default_gs_desc")
    end
    stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|cross_line_faild_title"))))
    stk_push_new_line(stk)
    v_data.total_score = data:get(packet.key.fate_servant_score).v_int
    stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|total_score"))))
    stk_push_new_line(stk)
  end
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("cross_line|fight_data"))))
  cloned_battle_deathcountd.mtf = stk.text
  g_timer_cloned_battle_over.suspended = false
  local fmt_add = ui.get_text("clonedbattle|quickly_challenge_over")
  local param_add = sys.variant()
  g_fmt_text = fmt_add
  g_cloned_battle_death_countdown = 10
  param_add:set("leave_time", g_cloned_battle_death_countdown)
  cloned_battle_deathcountd_add.mtf = sys.mtf_merge(param_add, fmt_add)
  g_send_cloned_battle_msg = true
  switch_cloned_battle_comment(false)
end
function visible_cb_count_down(data)
  if data == nil then
    return
  end
  g_cloned_battle_count_down.visible = data.vis
  g_cloned_battle_death_countdown = data.count_down
  cloned_battle_deathcountd.mtf = data.text
  g_timer_cloned_battle_over.suspended = false
  local fmt_add = data.fadd
  local param_add = sys.variant()
  g_fmt_text = fmt_add
  g_fmt_text_plus = data.fadd_plus
  if g_cloned_battle_death_countdown > 60 and data.fadd_plus ~= nil then
    local death_countdown = g_cloned_battle_death_countdown
    local iHour = math.floor(death_countdown / 3600)
    local v = math.fmod(death_countdown, 3600)
    local iMinute = math.floor(v / 60)
    local iSecond = math.fmod(v, 60)
    param_add:set("minute", iMinute)
    param_add:set("second", iSecond)
    local wstr_text = sys.mtf_merge(param, data.fadd_plus)
    param_add:set("leave_time", wstr_text)
  else
    param_add:set("leave_time", g_cloned_battle_death_countdown)
  end
  cloned_battle_deathcountd_add.mtf = sys.mtf_merge(param_add, fmt_add)
  g_send_cloned_battle_msg = data.msg
  switch_cloned_battle_comment(data.comment)
  if data.dy ~= nil and data.p_dy ~= nil and data.pp_dy ~= nil then
    ui_deathui.g_cloned_battle_count_down.dy = data.dy
    cloned_battle_deathcountd.parent.dy = data.p_dy
    cloned_battle_deathcountd.parent.parent.dy = data.pp_dy
  else
    cloned_battle_deathcountd.parent.dy = 190
    cloned_battle_deathcountd.parent.parent.dy = 230
  end
end
local set_cloned_battle_vip_exp = function(v_data)
  local _vp = 0
  local player = bo2.player
  if sys.check(player) then
    _vp = player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
    local hours = player:get_flag_int16(bo2.ePlayerFlagInt16_RMBPrivilegeHours)
    if hours <= 0 then
      _vp = 0
    end
  end
  local vip_excel = bo2.gv_supermarket_vip:find(_vp)
  if vip_excel ~= nil and 0 < vip_excel.cloneexp then
    v_data.sp_exp = math.floor(v_data.exp * vip_excel.cloneexp / 100)
  else
    v_data.sp_exp = 0
  end
  v_data.vip = sys.format(L("<vip:%d,3,8>"), _vp)
end
function set_cloned_battle_quickly_challenge_result_info(data, vis)
  if not vis then
    g_cloned_battle_count_down.visible = false
    return
  end
  local v_data = {}
  v_data.cd = ui_cloned_battle.g_cloned_battle_challenge_token
  v_data.char_name = data:get(packet.key.target_name).v_string
  if bo2.IsCoolDownOver(50025) ~= true then
    v_data.cd = 0
  end
  v_data.rank_id = data:get(packet.key.ranklist_id).v_int
  v_data.exp, v_data.rep, v_data.award_item = on_get_award_Data(v_data.rank_id, 1)
  set_cloned_battle_vip_exp(v_data)
  local stk_push_new_line = function(stk)
    stk:push("\n")
  end
  local stk = sys.stack()
  if v_data.rank_id <= 5 and ui_cloned_battle.g_self_info.ranklist_id > v_data.rank_id then
    stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("clonedbattle|quickly_challenge_sucessed_title2"))))
  else
    stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("clonedbattle|quickly_challenge_sucessed_title"))))
  end
  stk_push_new_line(stk)
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("clonedbattle|quickly_challenge_exp"))))
  stk_push_new_line(stk)
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("clonedbattle|quickly_challenge_rep"))))
  stk_push_new_line(stk)
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("clonedbattle|quickly_challenge_item"))))
  stk_push_new_line(stk)
  stk:push(ui_widget.merge_mtf(v_data, sys.format(ui.get_text("clonedbattle|quickly_challenge_today"))))
  stk_push_new_line(stk)
  local cb_data = {}
  cb_data.vis = true
  cb_data.count_down = 10
  cb_data.msg = false
  cb_data.comment = false
  cb_data.text = stk.text
  cb_data.fadd = ui.get_text("clonedbattle|quickly_challenge_over")
  visible_cb_count_down(cb_data)
end
function set_cloned_battle_result_info(data, vis)
  g_send_cloned_battle_msg = true
  g_cloned_battle_count_down.visible = vis
  if not vis then
    return
  end
  local v_data = {}
  v_data.second, v_data.hp_lost, v_data.bisha_times = get_knight_pk_data()
  v_data.char_name = data:get(packet.key.knight_pk_fighter_name).v_string
  v_data.exp = data:get(packet.key.knight_pk_exp).v_int
  v_data.cd = ui_cloned_battle.g_cloned_battle_challenge_token
  if bo2.IsCoolDownOver(50025) ~= true then
    v_data.cd = 0
  end
  v_data.rank_id = data:get(packet.key.ranklist_id).v_int
  g_cloned_battle_death_countdown = data:get(packet.key.knight_pk_leave_time).v_int
  local is_win = data:get(packet.key.cmn_rst).v_int
  v_data.exp, v_data.rep, v_data.award_item = on_get_award_Data(v_data.rank_id, is_win)
  set_cloned_battle_vip_exp(v_data)
  if is_win == 1 then
    if v_data.rank_id <= 5 and ui_cloned_battle.g_self_info.ranklist_id > v_data.rank_id then
      cloned_battle_deathcountd.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|cloned_battle_top_win")))
    else
      cloned_battle_deathcountd.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|cloned_battle_win")))
    end
  else
    cloned_battle_deathcountd.mtf = ui_widget.merge_mtf(v_data, sys.format(ui.get_text("common|cloned_battle_faild")))
  end
  g_timer_cloned_battle_over.suspended = false
  local fmt_add = ui.get_text("common|knight_over_leave_inf")
  g_fmt_text = fmt_add
  local param_add = sys.variant()
  param_add:set("leave_time", g_cloned_battle_death_countdown)
  cloned_battle_deathcountd_add.mtf = sys.mtf_merge(param_add, fmt_add)
  local rst_state_id = data:get(packet.key.marquee_type).v_int
  local rst_name = data:get(packet.key.target_masked_name).v_string
  if rst_state_id ~= 0 then
    switch_cloned_battle_comment(true)
    local rst_state_excel = bo2.gv_state_container:find(rst_state_id)
    if rst_state_excel ~= nil then
      local param = sys.variant()
      param:set("player_name", rst_name)
      param:set("state_name", rst_state_excel.name)
      local fmt = ui.get_text("common|death_add_state")
      local str = sys.mtf_merge(param, fmt)
      cloned_battle_state_comment_title.mtf = str
    end
    if is_win == 1 then
      btn_comment_flower.check = true
      btn_comment_bad_egg.check = false
    else
      btn_comment_flower.check = false
      btn_comment_bad_egg.check = true
    end
  else
    switch_cloned_battle_comment(false)
  end
end
function pcall(cmd, data)
  sys.cpu_pcall("test", on_closeUI, cmd, data)
end
reg(packet.eSTC_UI_Close_DeathUI, pcall, sig)
reg(packet.eSTC_Knight_PK_CloseUI, knight_close_over_UI, sig)
