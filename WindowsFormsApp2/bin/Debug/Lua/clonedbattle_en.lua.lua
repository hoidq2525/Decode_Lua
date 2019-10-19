local item_uri = L("$frame/clonedbattle/clonedbattle_en.xml")
local item_style = L("rank_item")
local cs_app_item_name = L("lb_name")
local cs_app_item_rank_list = L("lb_rank")
local cs_app_item_level = L("lb_level")
local cs_app_item_career = L("job")
local cs_app_item_portrait = "portrait"
local cs_app_item_fight_state = "fight_state"
local cs_lb_challenge_count = "lb_challenge_count"
local cs_may_fight = "$image/cha/portrait/btn/pkmode_1.png"
local cs_can_not_fight = "$image/cha/portrait/btn/figth_state.png"
local ci_cloned_battle_cooldown_token_excel_index = 50025
local n_page_limit = 10
local cwstr_cell_style_uri = L("$frame/clonedbattle/clonedbattle_en.xml")
local cwstr_history_item = L("fight_history_item")
local cwstr_cell_style_name = L("friend_assist_item")
local cwstr_cell_name = L("cell%d")
local g_challenge_table = {}
g_self_info = {}
local g_history_data = {}
local g_friend_ass_data = {}
local g_select_item_name
local g_challenge_rank_id = 0
local g_view_cloned_battle = true
local g_season_award_time = 0
local g_last_season_award = 0
local g_cloned_battle_history_stamp = 0
g_cloned_battle_challenge_token = 10
function on_init_token()
  local token_excel = bo2.gv_cooldown_list:find(ci_cloned_battle_cooldown_token_excel_index)
  if sys.check(token_excel) then
    g_cloned_battle_challenge_token = token_excel.token
  end
end
on_init_token()
g_token_refresh_time = nil
is_friend_assist_knight = false
local g_award_max_rank = 10000
local g_season_award_per = 5
local g_self_being_challenge_cool_down_id = 50023
local g_self_challenge_cool_down_id = 50024
local g_season_award_cool_down_id = 50047
local g_first_season_day = 3
local g_second_season_day = 7
local g_nofitied_flicker = false
g_append_time_item = nil
function on_init_once()
  g_nofitied_flicker = true
  cs_default_cloned_battle_npc_name = ui.get_text("clonedbattle|cs_default_cloned_battle_npc_name")
end
on_init_once()
local stk_push_new_line = function(stk)
  stk:push("\n")
end
local stk_push_space = function(stk)
  stk:push(" ")
end
local stk_push_sep = function(stk)
  stk:push([[
<tf+:micro>
<sep>
<tf->]])
end
local stk_push_color_red = function(stk)
  stk:push("<c+:C92B2B>")
end
local stk_push_color_blue = function(stk)
  stk:push("<c+:17A6DB>")
end
local stk_push_color_gray = function(stk)
  stk:push("<c+:979797>")
end
local stk_push_color_end = function(stk)
  stk:push("<c->")
end
local stk_push_edge_full = function(stk, _font, size)
  stk:push(sys.format(L("<lb:%s,%d,full,,100|"), _font, size))
end
local stk_push_edge_full_end = function(stk)
  stk:push(">")
end
local space_line_one = 1
local space_line_two = 3
local stk_push_space = function(stk, _space)
  for i = 1, _space do
    stk:push("  ")
  end
end
local function stk_push_line_text(stk, text, color_fn, _size, _font, _space, _noline)
  if color_fn ~= nil then
    color_fn(stk)
  end
  if _font == nil then
    _font = "art"
  end
  if _size == nil then
    _size = 14
  end
  if _space ~= nil then
    stk_push_space(stk, _space)
  end
  stk_push_edge_full(stk, _font, _size)
  stk:push(text)
  stk_push_edge_full_end(stk)
  if _noline == nil then
    stk_push_new_line(stk)
  end
  if color_fn ~= nil then
    stk_push_color_end(stk)
  end
end
function OnCleanChallengeTable()
  g_challenge_table = {}
end
function OnCleanMemoryData()
  OnCleanChallengeTable()
  g_self_info = {}
  g_cloned_battle_history_stamp = 0
end
local get_challenge_excel = function()
  local self_rank = g_self_info.ranklist_id
  local size = bo2.gv_cloned_battle_challenge_index.size
  for i = 0, size - 1 do
    local excel = bo2.gv_cloned_battle_challenge_index:get(i)
    if self_rank <= excel.cur_stage or 0 > excel.cur_stage then
      return excel
    end
  end
end
local function get_quickly_challenge_data()
  local _value = {}
  _value.value = g_self_info.gs_score
  _value.persent = 150
  local challenge_excel = get_challenge_excel()
  if sys.check(challenge_excel) then
    _value.value = g_self_info.gs_score / challenge_excel.quickly_challenge_value * 100
    _value.value = math.floor(_value.value)
    _value.persent = challenge_excel.quickly_challenge_value
  end
  return _value
end
function on_check_end_of_season()
  do return false end
  local _get_time = function()
    if g_debug ~= nil then
      return os.time()
    else
      return ui_main.get_os_time()
    end
  end
  local os_time = _get_time()
  local _day = tonumber(os.date("%d", os.time()))
  if _day < 28 then
    return false
  end
  local _month = tonumber(os.date("%m", os.time()))
  if _month == 1 or _month == 3 or _month == 5 or _month == 7 or _month == 8 or _month == 10 or _month == 12 then
    if _day == 31 then
      return true
    end
  elseif _month == 2 then
    if _day == 28 or _day == 29 then
      return true
    end
  elseif _day == 30 then
    return true
  end
  return false
end
function get_time_text_by_second(second)
  local wstr_text
  local iHour = math.floor(second / 3600)
  local v = math.fmod(second, 3600)
  local iMinute = math.floor(v / 60)
  local iSecond = math.fmod(v, 60)
  local time_data = {}
  if iMinute >= 10 then
    time_data.minute = sys.format("%d", iMinute)
  else
    time_data.minute = sys.format(L("0%d"), iMinute)
  end
  if iSecond >= 10 then
    time_data.second = sys.format("%d", iSecond)
  else
    time_data.second = sys.format(L("0%d"), iSecond)
  end
  wstr_text = ui_widget.merge_mtf(time_data, ui.get_text("clonedbattle|set_time"))
  return wstr_text
end
function on_timer_set_self_time()
  local item_fight_state = lb_challenge_state
  if g_self_info.time_second ~= nil and g_self_info.time_second > 0 then
    item_fight_state.text = sys.format(L("%s"), get_time_text_by_second(g_self_info.time_second))
    item_fight_state.tip.text = item_fight_state.text
    item_fight_state.visible = true
  else
    item_fight_state.visible = false
  end
end
function switch_fight_state(item, fight_state)
  local item_fight_state = item:search(cs_app_item_fight_state)
  if fight_state == 0 then
    item_fight_state.image = cs_may_fight
  else
    item_fight_state.image = cs_can_not_fight
  end
end
function get_safe_persent(win, total)
  if total == 0 then
    return 0
  else
    return win / total * 100
  end
end
function on_refresh_self_data_tips()
  local stk = sys.stack()
  stk:push(ui.get_text("clonedbattle|challenge_times"))
  stk:push(g_self_info.challenge_times)
  stk_push_new_line(stk)
  g_self_info.win_persent = sys.format("%.1f%%", get_safe_persent(g_self_info.challenge_win_times, g_self_info.challenge_times))
  stk:push(ui_widget.merge_mtf(g_self_info, ui.get_text("clonedbattle|win_persent_data")))
  stk_push_new_line(stk)
  stk:push(ui.get_text("clonedbattle|defence_times"))
  stk:push(g_self_info.defence_times)
  stk_push_new_line(stk)
  g_self_info.defence_persent = sys.format("%.1f%%", get_safe_persent(g_self_info.defence_win_times, g_self_info.defence_times))
  stk:push(ui_widget.merge_mtf(g_self_info, ui.get_text("clonedbattle|defence_persetnt_data")))
  stk_push_new_line(stk)
  stk:push(ui.get_text("clonedbattle|top_rank"))
  stk:push(sys.format("<c+:00ff00>%d<c->", g_self_info.topest_rank_id))
  stk_push_new_line(stk)
  stk:push(ui.get_text("clonedbattle|current_streak"))
  stk:push(g_self_info.win_streak)
  stk_push_new_line(stk)
  stk:push(ui.get_text("clonedbattle|flower"))
  stk:push(g_self_info.flower)
  stk_push_new_line(stk)
  stk:push(ui.get_text("clonedbattle|bad_egg"))
  stk:push(g_self_info.bad_egg)
  stk_push_new_line(stk)
  stk:push(ui.get_text("clonedbattle|gs_score"))
  stk:push(g_self_info.gs_score)
  stk_push_new_line(stk)
  local _value = get_quickly_challenge_data()
  stk:push(ui_widget.merge_mtf(_value, ui.get_text("clonedbattle|quickly_challenge_value")))
  ui_cloned_battle.w_tip.tip.text = stk.text
end
function on_set_self_data()
  on_timer_set_self_time()
  local item_rank_id = ui_cloned_battle.w_self_info:search(cs_app_item_rank_list)
  item_rank_id.text = g_self_info.ranklist_id
  on_refresh_current_rank_award()
  on_refresh_self_data_tips()
end
function on_handle_self_data(cmd, data)
  local on_time_event = function()
    ui_cloned_battle.g_append_time_item = nil
  end
  g_self_info.fight_state = data:get(packet.key.scnobj_type).v_int
  g_self_info.time_second = data:get(packet.key.org_time).v_int
  if g_self_info.time_second > 0 then
    g_self_info.time_second = g_self_info.time_second + 1
    if ui_reciprocal.find_reciproca("clonedbattle") == nil then
      ui_reciprocal.del_reciproca("clonedbattle")
      local insert_sub = {}
      insert_sub.time = g_self_info.time_second
      insert_sub.name = ui.get_text("clonedbattle|cloned_battle_name")
      insert_sub.close = true
      insert_sub.callback = on_time_event
      ui_reciprocal.add_reciproca("clonedbattle", insert_sub)
    end
  end
  g_self_info.challenge_win_times = data:get(packet.key.action_win).v_int
  g_self_info.challenge_times = data:get(packet.key.battle_usetime).v_int
  g_self_info.defence_win_times = data:get(packet.key.dooaltar_win).v_int
  g_self_info.defence_times = data:get(packet.key.marquee_times).v_int
  g_self_info.topest_rank_id = data:get(packet.key.ranklist_maxnum).v_int
  g_self_info.win_streak = data:get(packet.key.scnmatch_win_type).v_int
  check_may_start_timer(g_self_info.time_second)
  if data:has(packet.key.ranklist_id) then
    g_self_info.ranklist_id = data:get(packet.key.ranklist_id).v_int
  end
  g_season_award_time = data:get(packet.key.has_award).v_int
  g_self_info.flower = data:get(packet.key.pet_hole_kidney).v_int
  g_self_info.bad_egg = data:get(packet.key.pet_hole_reopen).v_int
  g_self_info.gs_score = data:get(packet.key.fate_score).v_int
  on_set_self_data()
  local _month = tonumber(os.date("%m", os.time()))
  _month = _month + 1
  if _month > 12 then
    _month = 1
  end
  local reset_data = {}
  reset_data.month = _month
  ui_cloned_battle.w_reset_desc.mtf = ui_widget.merge_mtf(reset_data, ui.get_text("clonedbattle|reset_desc"))
  local tip = ui_cloned_battle.w_reset_desc.parent.tip
  tip.text = ui_widget.merge_mtf(reset_data, ui.get_text("clonedbattle|reset_desc_tip"))
  w_main.visible = true
end
function on_cancel_all_item_highlight()
  for i = 0, 4 do
    local item_name = sys.format(L("item%d"), i)
    local item = ui_cloned_battle.g_challenge_list:search(item_name)
    if sys.check(item) then
      local highlight = item:search(L("highlight_select"))
      if sys.check(highlight) then
        highlight.visible = false
      end
    end
  end
end
function on_mouse_chellange_item(w, msg, pos, wheel)
  if msg == ui.mouse_inner then
    on_cancel_all_item_highlight()
    local highlight = w:search(L("highlight_select"))
    if sys.check(highlight) then
      highlight.visible = true
    end
    local flash = w:search("flash")
    if sys.check(flash) then
      flash.visible = false
    end
  elseif msg == ui.mouse_outer then
    local highlight = w:search(L("highlight_select"))
    if sys.check(highlight) then
      highlight.visible = false
    end
    local gs_score = w.var:get(packet.key.fate_score).v_int
    if gs_score > 0 then
      local _value = get_quickly_challenge_data()
      local flash = w:search("flash")
      if gs_score < _value.value and sys.check(flash) then
        flash.visible = true
      end
    end
  elseif msg == ui.mouse_lbutton_click or msg == ui.mouse_lbutton_dbl then
    do
      local rank_index = w.var:get(packet.key.ranklist_id).v_int
      local function on_manual_challenge()
        if rank_index > 0 then
          ui_cloned_battle.w_main.visible = false
          ui_cloned_battle.is_friend_assist_knight = false
          ui_cloned_battle.w_main_friend_assist.visible = true
          g_challenge_rank_id = rank_index
        end
      end
      local _value = get_quickly_challenge_data()
      local gs_score = w.var:get(packet.key.fate_score).v_int
      if sys.check(bo2.player) and gs_score >= 0 and gs_score < _value.value then
        local function on_msg_callback(msg)
          if msg.result == 1 then
            local v = sys.variant()
            v:set(packet.key.ranklist_id, rank_index)
            bo2.send_variant(packet.eCTS_UI_ClonedBattle_QuicklyChallenge, v)
            w_main.visible = false
            return
          end
          on_manual_challenge()
        end
        local msg = {
          callback = on_msg_callback,
          text = ui.get_text("clonedbattle|auto_challenge")
        }
        ui_widget.ui_msg_box.show_common(msg)
      else
        on_manual_challenge()
      end
    end
  end
end
function Clear_Challenge_Item()
  for i = 0, 4 do
    local item_name = sys.format(L("item%d"), i)
    local item = ui_cloned_battle.g_challenge_list:search(item_name)
    if sys.check(item) then
      item.visible = false
    end
  end
end
function set_rank_item_tip_text(stk, app_item, item_data)
  local lb_level = app_item:search(cs_app_item_level)
  local get_single_challenge_excel = function(rank_id)
    local nSize = bo2.gv_cloned_battle_single_challenge_award.size
    for i = 0, nSize - 1 do
      local pExcel = bo2.gv_cloned_battle_single_challenge_award:get(i)
      if rank_id <= pExcel.cur_level or 0 > pExcel.cur_level then
        return pExcel
      end
    end
    return nil
  end
  local award_excel = get_single_challenge_excel(item_data.ranklist_id)
  local add_on_change = false
  local function add_challenge_award(stk, level, award_excel)
    stk:push([[
<tf+:micro>
<sep>
<tf->]])
    local win_exp = level * 100 + 1000
    local lose_exp = level * 50 + 1000
    if award_excel ~= nil then
      win_exp = level * award_excel.win_award_exp_per + award_excel.win_award_money
      lose_exp = level * award_excel.fail_award_exp_per + award_excel.fail_award_money
    end
    stk_push_line_text(stk, ui.get_text("clonedbattle|win_award_text"), stk_push_color_red, 16, "art", space_line_one)
    local exp_text = ui_widget.merge_mtf({exp = win_exp}, ui.get_text("clonedbattle|win_exp"))
    stk_push_line_text(stk, exp_text, nil, nil, "plain", space_line_two)
    local win_reknow = ui_widget.merge_mtf({count = 10}, ui.get_text("clonedbattle|win_reknow"))
    stk_push_line_text(stk, win_reknow, nil, nil, "plain", space_line_two)
    if award_excel ~= nil and award_excel.award_item_index ~= 0 and award_excel.award_item_num ~= 0 then
      local item_text = sys.format("<i:%d> x %d", award_excel.award_item_index, award_excel.award_item_num)
      local item_full_text = ui_widget.merge_mtf({item = item_text}, ui.get_text("clonedbattle|win_item"))
      stk_push_space(stk, space_line_two)
      stk:push(item_full_text)
      stk_push_new_line(stk)
    end
    stk_push_line_text(stk, ui.get_text("clonedbattle|faild_award_text"), stk_push_color_gray, 16, "art", space_line_one)
    local faild_exp_text = ui_widget.merge_mtf({exp = lose_exp}, ui.get_text("clonedbattle|win_exp"))
    stk_push_line_text(stk, faild_exp_text, nil, nil, "plain", space_line_two)
    local lose_reknow = ui_widget.merge_mtf({count = 5}, ui.get_text("clonedbattle|win_reknow"))
    stk_push_line_text(stk, lose_reknow, nil, nil, "plain", space_line_two)
  end
  local function on_test_no_change(stk, rank_id)
    if rank_id > g_self_info.ranklist_id then
      stk:push([[
<tf+:micro>
<sep>
<tf->]])
      stk_push_color_red(stk)
      stk:push(ui.get_text("clonedbattle|high_rank"))
      stk_push_color_end(stk)
      return true
    end
    return false
  end
  if item_data.is_npc then
    local rank_data = ui_widget.merge_mtf({
      rank = item_data.ranklist_id
    }, ui.get_text("clonedbattle|rank"))
    stk_push_line_text(stk, rank_data, stk_push_color_blue, 18, nil, space_line_one)
    stk_push_line_text(stk, cs_default_cloned_battle_npc_name, nil, 16, nil, space_line_one)
    local level_text = sys.format("Lv%s", lb_level.text)
    stk_push_line_text(stk, level_text, stk_push_color_gray, 16, nil, space_line_one)
  else
    local rank_data = ui_widget.merge_mtf({
      rank = item_data.ranklist_id
    }, ui.get_text("clonedbattle|rank"))
    stk_push_line_text(stk, rank_data, stk_push_color_blue, 18, nil, space_line_one)
    stk_push_line_text(stk, item_data.cha_name, nil, 16, nil, space_line_one)
    local level_text = sys.format("Lv%s", lb_level.text)
    stk_push_line_text(stk, level_text, stk_push_color_gray, 16, nil, space_line_one)
    local pro = bo2.gv_profession_list:find(item_data.career)
    if pro then
      stk_push_line_text(stk, pro.name, stk_push_color_gray, 16, nil, space_line_one)
    end
    if sys.check(item_data.guild_name) and item_data.guild_name.size > 1 then
      local npc_guild_name = ui.check_npc_guild(item_data.guild_name)
      local guild_name = ui_widget.merge_mtf({guild = npc_guild_name}, ui.get_text("clonedbattle|guild_name"))
      stk_push_line_text(stk, guild_name, stk_push_color_gray, 16, nil, space_line_one)
    end
    local win_data = {}
    win_data.challenge_win_times = item_data.challenge_win_times
    win_data.challenge_times = item_data.challenge_times
    win_data.win_persent = sys.format(L("%.1f%%"), get_safe_persent(item_data.challenge_win_times, item_data.challenge_times))
    local challenge_text = ui_widget.merge_mtf(win_data, ui.get_text("clonedbattle|win_persent_data"))
    stk_push_line_text(stk, challenge_text, stk_push_color_gray, nil, "plain")
    local defence_data = {}
    defence_data.defence_persent = sys.format(L("%.1f%%"), get_safe_persent(item_data.defence_win_times, item_data.defence_times))
    defence_data.defence_win_times = item_data.defence_win_times
    defence_data.defence_times = item_data.defence_times
    local defence_text = ui_widget.merge_mtf(defence_data, ui.get_text("clonedbattle|defence_persetnt_data"))
    stk_push_line_text(stk, defence_text, stk_push_color_gray, nil, "plain")
    stk:push([[
<tf+:micro>
<sep>
<tf->]])
    stk_push_line_text(stk, ui.get_text("clonedbattle|quickly_challenge_title"), stk_push_color_red, 16, "art", space_line_one)
    local target_gs_info = ui_widget.merge_mtf({
      gs_score = item_data.gs_score
    }, ui.get_text("clonedbattle|target_gs_score"))
    stk_push_line_text(stk, target_gs_info, stk_push_color_gray, nil, "plain")
    local _value = get_quickly_challenge_data()
    if item_data.gs_score >= _value.value then
      stk_push_line_text(stk, ui.get_text("clonedbattle|quickly_challenge_faild"), stk_push_color_gray, nil, "plain")
    else
      stk_push_line_text(stk, ui.get_text("clonedbattle|may_quickly_challenge"), stk_push_color_blue, nil, "plain")
    end
  end
  add_on_change = on_test_no_change(stk, item_data.ranklist_id)
  if sys.check(bo2.player) then
    add_challenge_award(stk, bo2.player:get_atb(bo2.eAtb_Level), award_excel)
  end
  local function add_season_award(stk, item_data)
    local rank_id = item_data.ranklist_id
    local mb_data_size = bo2.gv_cloned_battle_season_award.size
    for i = 0, mb_data_size - 1 do
      local mb_excel = bo2.gv_cloned_battle_season_award:get(i)
      if mb_excel and rank_id <= mb_excel.cur_level then
        stk:push([[
<tf+:micro>
<sep>
<tf->]])
        local _space
        if add_on_change then
          _space = space_line_one
        end
        stk_push_line_text(stk, ui.get_text("clonedbattle|rank_award"), stk_push_color_red, 16, "art", _space)
        local money = mb_excel.award_money
        if rank_id <= g_award_max_rank then
          money = money + (g_award_max_rank - rank_id) * g_season_award_per
          if money < 0 then
            money = mb_excel.award_money
          end
        end
        local money_text = sys.format(L("<bm:%d>"), money)
        stk_push_space(stk, space_line_two)
        stk:push(money_text)
        stk_push_new_line(stk)
        local repute_text = ui_widget.merge_mtf({
          repute = mb_excel.award_repute
        }, ui.get_text("clonedbattle|rank_repute"))
        stk_push_line_text(stk, repute_text, nil, nil, "plain", space_line_two)
        if mb_excel.award_item ~= 0 then
          local item_text = ui_widget.merge_mtf({
            item = sys.format(L("<i:%d> x 1"), mb_excel.award_item)
          }, ui.get_text("clonedbattle|rank_item"))
          stk_push_space(stk, space_line_two)
          stk:push(item_text)
          stk_push_new_line(stk)
        end
        return
      end
    end
  end
  add_season_award(stk, item_data)
  if item_data.time_second == 0 then
    stk_push_line_text(stk, ui.get_text("clonedbattle|click_challenge"), stk_push_color_gray, 16, "art", 1, space_line_one)
  else
    stk_push_line_text(stk, get_time_text_by_second(item_data.time_second), stk_push_color_gray, 14, "art", 1, space_line_one)
  end
end
function on_show_rank_item_tips(tip)
  local index = tip.owner.var:get(packet.key.item_key).v_int
  index = index + 1
  if g_challenge_table[index] == nil then
    return
  end
  local app_item = tip.owner
  local item_data = g_challenge_table[index]
  local stk = sys.stack()
  set_rank_item_tip_text(stk, app_item, item_data)
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function ModiftyChallengeItemTip(app_item, item_data)
  local stk = sys.stack()
  set_rank_item_tip_text(stk, app_item, item_data)
  app_item.tip.text = stk.text
end
function ModiftyChallengeItem(app_item, item_data)
  local flash = app_item:search(L("flash"))
  if sys.check(flash) then
    flash.visible = false
  end
  app_item.var:set(packet.key.ranklist_id, item_data.ranklist_id)
  local lb_rank_list = app_item:search(cs_app_item_rank_list)
  if sys.check(lb_rank_list) then
    lb_rank_list.text = item_data.ranklist_id
  end
  local lb_name = app_item:search(cs_app_item_name)
  local career_panel = app_item:search(cs_app_item_career)
  if item_data.is_npc then
    lb_name.text = cs_default_cloned_battle_npc_name
    career_panel.visible = false
    local lb_level = app_item:search(cs_app_item_level)
    lb_level.text = bo2.player:get_atb(bo2.eAtb_Level)
    local portrait = app_item:search(cs_app_item_portrait)
    portrait.image = sys.format("$icon/portrait/zj/0000.png")
    portrait.visible = true
    app_item.var:set(packet.key.fate_score, -1)
  else
    lb_name.text = item_data.cha_name
    local lb_level = app_item:search(cs_app_item_level)
    lb_level.text = item_data.level
    local career_idx = 0
    local pro = bo2.gv_profession_list:find(item_data.career)
    local set_image = false
    if pro == nil then
      career_idx = 0
    else
      career_idx = pro.career - 1
      if career_idx >= 6 then
        career_idx = career_idx + 1
        career_panel.image = L("$image/widget/btn/career.png")
        career_panel.irect = ui.rect(career_idx * 21 + 1, 46, (career_idx + 1) * 21, 77)
        set_image = true
      end
    end
    if set_image ~= true then
      career_panel.image = L("$image/cha/portrait/career.png")
      career_panel.irect = ui.rect(career_idx * 21, 0, (career_idx + 1) * 21, 32)
    end
    career_panel.svar = career
    career_panel.visible = true
    local por_list = bo2.gv_portrait:find(item_data.portrait)
    local portrait = app_item:search(cs_app_item_portrait)
    if por_list ~= nil then
      portrait.image = sys.format("$icon/portrait/%s.png", por_list.icon)
      portrait.visible = true
    end
    app_item.var:set(packet.key.fate_score, item_data.gs_score)
    local _value = get_quickly_challenge_data()
    if _value.value > item_data.gs_score and sys.check(flash) then
      flash.visible = true
    end
  end
  ModiftyChallengeItemTip(app_item, item_data)
end
function Insert_Challenge_Item(index, item_data)
  local item_name = sys.format(L("item%d"), index)
  local item = g_challenge_list:search(item_name)
  if sys.check(item) ~= true then
    return
  end
  item.visible = true
  ModiftyChallengeItem(item, item_data)
  item.var:set(packet.key.item_key, index)
end
function RebulidRankList()
  function fn_sort_data(left, right)
    if left.ranklist_id < right.ranklist_id then
      return true
    end
    return false
  end
  table.sort(g_challenge_table, fn_sort_data)
  Clear_Challenge_Item()
  local index = 0
  for i, v in pairs(g_challenge_table) do
    Insert_Challenge_Item(index, v)
    index = index + 1
  end
  local nSize = #g_challenge_table
  if nSize == 0 then
  else
    if nSize < 5 then
      local iDx = (470 - nSize * 92) / 2
    else
    end
  end
end
function on_set_challenge_table(v_data)
  local ranklist_id = v_data:get(packet.key.ranklist_id).v_int
  if ranklist_id ~= 0 then
    local v = {}
    local is_npc = v_data:get(packet.key.talk_questnpc_id).v_int
    v.ranklist_id = ranklist_id
    v.fight_state = v_data:get(packet.key.scnobj_type).v_int
    v.cha_onlyid = v_data:get(packet.key.cha_onlyid).v_string
    v.time_second = v_data:get(packet.key.org_time).v_int
    v.challenge_win_times = v_data:get(packet.key.action_win).v_int
    v.challenge_times = v_data:get(packet.key.battle_usetime).v_int
    v.defence_win_times = v_data:get(packet.key.dooaltar_win).v_int
    v.defence_times = v_data:get(packet.key.marquee_times).v_int
    v.guild_name = v_data:get(packet.key.guild_name).v_string
    check_may_start_timer(v.time_second)
    v.empty = false
    if is_npc == 1 then
      v.is_npc = true
    else
      v.cha_name = v_data:get(packet.key.cha_name).v_string
      v.level = v_data:get(packet.key.cha_level).v_int
      v.career = v_data:get(packet.key.sociality_playercareer).v_int
      v.portrait = v_data:get(packet.key.cha_portrait).v_int
      v.gs_score = v_data:get(packet.key.fate_score).v_int
    end
    return v
  end
  return nil
end
function on_handle_rank_list_data(cmd, data)
  OnCleanChallengeTable()
  local vDataSize = data.size
  for i = 0, vDataSize - 1 do
    local v_data = data:get(i)
    local v = on_set_challenge_table(v_data)
    if v ~= nil then
      table.insert(g_challenge_table, v)
    end
  end
  RebulidRankList()
end
function on_init_public_info_text()
  g_public_info_common.visible = true
  local function on_get_current_text()
    if on_check_end_of_season() == true then
      local rand_count = bo2.rand(1, 3)
      local rand_text = sys.format("clonedbattle|month_award_notify_%d", rand_count)
      return ui.get_text(rand_text)
    else
      local rank_id = 1
      if g_self_info ~= nil and g_self_info.ranklist_id ~= nil then
        rank_id = g_self_info.ranklist_id
      end
      if rank_id == nil or rank_id > g_award_max_rank or rank_id <= 0 then
        return ui.get_text("clonedbattle|init_public_info")
      else
        return L("")
      end
    end
  end
  g_public_info_common.text = on_get_current_text()
  g_public_info_common.parent:tune("public_info")
end
function on_handle_public_info(cmn, data)
  if on_check_end_of_season() == true then
    return false
  end
  local public_info_type = data:get(packet.key.cmn_type).v_int
  local actor_name = data:get(packet.key.cha_name).v_string
  local iData = data:get(packet.key.cmn_dataobj).v_int
  local set_text
  local stk = sys.stack()
  stk:push(set_text)
  if public_info_type == bo2.eClonedBattlePublicInfoType_WinningStreak then
    local actor_data = {}
    actor_data.actor_name = sys.format(L("<q_user:%s,C92B2B>"), actor_name)
    actor_data.iData = sys.format("<c+:17A6DB>%d<c->", iData)
    stk:push(ui_widget.merge_mtf(actor_data, ui.get_text("clonedbattle|streak")))
  elseif public_info_type == bo2.eClonedBattlePublicInfoType_TopChallenge then
    local actor_data = {}
    local target_name = data:get(packet.key.target_name).v_string
    if target_name.size <= 1 then
      actor_data.target_name = sys.format(L("<c+:B4B4B4>%s<c->"), cs_default_cloned_battle_npc_name)
    else
      actor_data.target_name = sys.format(L("<q_user:%s,B4B4B4>"), target_name)
    end
    actor_data.actor_name = sys.format(L("<q_user:%s,C92B2B>"), actor_name)
    actor_data.iData = iData
    stk:push(ui_widget.merge_mtf(actor_data, ui.get_text("clonedbattle|top_history")))
  end
  g_public_info_common.mtf = stk.text
  g_public_info_common.visible = true
  g_public_info_common.parent:tune("public_info")
end
function on_handle_dirty_data(cmd, data)
  local vDataSize = data.size
  local bRebuild = false
  for i = 0, vDataSize - 1 do
    local v_data = data:get(i)
    local v_type = v_data:get(packet.key.cmn_type).v_int
    if v_type == bo2.eClonedBattleDirtyDataType_SelfData then
      local tmp_var = v_data:get(packet.key.ranklist_data)
      on_handle_self_data(0, tmp_var)
    elseif v_type == bo2.eClonedBattleDirtyDataType_RankListData then
      local tmp_var = v_data:get(packet.key.ranklist_data)
      local vPacketData = on_set_challenge_table(tmp_var)
      if vPacketData == nil then
        break
      end
      for i, v in pairs(g_challenge_table) do
        if v.ranklist_id == vPacketData.ranklist_id then
          g_challenge_table[i] = vPacketData
          bRebuild = true
          break
        end
      end
    end
  end
  if bRebuild then
    RebulidRankList()
  end
end
function refresh_token_time()
  if bo2.IsCoolDownOver(ci_cloned_battle_cooldown_token_excel_index) ~= true then
    g_cloned_battle_challenge_token = 0
  end
  local times_text = sys.format("%d", g_cloned_battle_challenge_token)
  local mtf_text = ui.get_text("clonedbattle|today_token")
  local _vp = 0
  if sys.check(bo2.player) then
    _vp = bo2.player:get_flag_int8(bo2.ePlayerFlagInt8_RMBPrivilege)
  end
  g_challenge_times.text = ui_widget.merge_mtf({times = times_text}, mtf_text)
  g_challenge_times.tip.text = g_challenge_times.text
  g_vip_desc.mtf = ui_widget.merge_mtf({vp = _vp}, ui.get_text("clonedbattle|vip_desc"))
end
function on_handle_cooldown_token(cmd, data)
  local iExcelId = data:get(packet.key.cooldown_id).v_int
  local token = data:get(packet.key.cooldown_token).v_int
  if iExcelId == ci_cloned_battle_cooldown_token_excel_index then
    local mb_data = bo2.gv_cooldown_list:find(iExcelId)
    if mb_data ~= nil then
      local lb_challenge_count = ui_cloned_battle.w_self_info:search(cs_lb_challenge_count)
      g_cloned_battle_challenge_token = token
      refresh_token_time()
    end
  end
end
function check_notify_qlink_flicker()
  if ui_cloned_battle.w_main.visible ~= true then
    ui_handson_teach.w_flicker_cloned_battle.visible = true
    g_nofitied_flicker = false
  end
end
function disable_notify_qlink_flicker()
  ui_handson_teach.w_flicker_cloned_battle.visible = false
  g_nofitied_flicker = false
end
function check_may_start_timer(second)
  if second then
    ui_cloned_battle.g_timer_second.suspended = false
  end
end
function on_cloned_battle_self_enter()
  if g_nofitied_flicker == true and bo2.IsCoolDownOver(g_self_being_challenge_cool_down_id) and bo2.IsCoolDownOver(g_self_challenge_cool_down_id) and bo2.IsCoolDownOver(ci_cloned_battle_cooldown_token_excel_index) then
    check_notify_qlink_flicker()
  end
end
function on_timer_set_second_text()
  local bStop = true
  ui_cloned_battle.on_timer_set_self_time()
  if g_self_info.time_second ~= nil and g_self_info.time_second > 0 then
    g_self_info.time_second = g_self_info.time_second - 1
    if g_self_info.time_second <= 0 then
      g_self_info.time_second = 0
      local item_fight_state = lb_challenge_state
      if sys.check(item_fight_state) then
        item_fight_state.visible = false
      end
      g_nofitied_flicker = true
      on_cloned_battle_self_enter()
    else
      bStop = false
    end
  end
  local idx = 0
  for i, v in pairs(g_challenge_table) do
    if v.time_second > 0 then
      local item_name = sys.format(L("item%d"), idx)
      local item = ui_cloned_battle.g_challenge_list:search(item_name)
      v.time_second = v.time_second - 1
      if v.time_second > 0 then
        bStop = false
      end
      if item ~= nil then
        ModiftyChallengeItemTip(item, v)
      end
    end
    idx = idx + 1
  end
  if bStop then
    ui_cloned_battle.g_timer_second.suspended = true
  end
end
function on_click_challenge_target(btn)
  local rank_index = btn.var:get(packet.key.ranklist_id).v_int
  if rank_index > 0 then
    ui_cloned_battle.w_main.visible = false
    ui_cloned_battle.w_main_friend_assist.visible = true
    g_challenge_rank_id = rank_index
  end
end
function on_timer_set_history_text()
  fresh_cloned_battle_history_data(false)
  on_refresh_current_rank_award()
end
function on_handle_history_stamp(cmd, data)
  local server_stamp = data:get(packet.key.cmn_id).v_int
  if server_stamp ~= g_cloned_battle_history_stamp then
    local v = sys.variant()
    v:set(packet.key.cmn_id, g_cloned_battle_history_stamp)
    bo2.send_variant(packet.eCTS_Sociality_ClientHistoryStamp, v)
  else
    fresh_cloned_battle_history_data()
  end
end
function fresh_cloned_battle_history_data(bRebuild)
  local set_item_data = function(item, data)
    local rst = data:get(packet.key.cmn_rst).v_int
    local rst_rank_id = data:get(packet.key.ranklist_id).v_int
    local target_name = data:get(packet.key.cmn_name).v_string
    local mtf_name
    if target_name == L("") then
      target_name = cs_default_cloned_battle_npc_name
      mtf_name = sys.format(L("<c+:C92B2B>%s<c->"), target_name)
    else
      mtf_name = sys.format(L("<q_user:%s,C92B2B>"), target_name)
    end
    local cmn_type = data:get(packet.key.cmn_type).v_int
    local _last_time = data:get(packet.key.action_time).v_int
    local current_time = ui_main.get_os_time()
    local second = os.difftime(current_time, _last_time)
    local text
    local fn_make_time_text = function(second)
      if second < 60 then
        return ui.get_text("clonedbattle|sort_time")
      end
      local iHour = math.floor(second / 3600)
      local v = math.fmod(second, 3600)
      local iMinute = math.floor(v / 60)
      if iHour <= 0 then
        return ui_widget.merge_mtf({Minute = iMinute}, ui.get_text("clonedbattle|mintue_before"))
      elseif iHour <= 24 then
        return ui_widget.merge_mtf({Hour = iHour}, ui.get_text("clonedbattle|hours_before"))
      else
        local iData = math.floor(iHour / 24)
        if iData > 30 then
          return ui.get_text("clonedbattle|n_day_before")
        else
          return ui_widget.merge_mtf({Day = iData}, ui.get_text("clonedbattle|day_before"))
        end
      end
    end
    local time_text = fn_make_time_text(second)
    local rst_rank_text = sys.format("<c+:FF17A6DB>%d<c->", rst_rank_id)
    if cmn_type == 0 then
      if rst == 1 then
        if rst_rank_id == 0 then
          text = ui_widget.merge_mtf({time = time_text, name = mtf_name}, ui.get_text("clonedbattle|common_win"))
        else
          text = ui_widget.merge_mtf({
            time = time_text,
            name = mtf_name,
            rank = rst_rank_text
          }, ui.get_text("clonedbattle|rank_win_text"))
        end
      else
        text = ui_widget.merge_mtf({
          time = time_text,
          name = mtf_name,
          rank = rst_rank_text
        }, ui.get_text("clonedbattle|chanllenge_faild_text"))
      end
    elseif rst == 1 then
      text = ui_widget.merge_mtf({
        time = time_text,
        name = mtf_name,
        rank = rst_rank_text
      }, ui.get_text("clonedbattle|defence_win_text"))
    elseif rst_rank_id == 0 then
      text = ui_widget.merge_mtf({
        time = time_text,
        name = mtf_name,
        rank = rst_rank_text
      }, ui.get_text("clonedbattle|defence_common_text"))
    else
      text = ui_widget.merge_mtf({
        time = time_text,
        name = mtf_name,
        rank = rst_rank_text
      }, ui.get_text("clonedbattle|defence_lose_text"))
    end
    local win_pic = item:search("win_pic")
    local lose_pic = item:search("lose_pic")
    local stk = sys.stack()
    if rst == 1 then
      win_pic.visible = true
      lose_pic.visible = false
      stk:push(text)
    else
      win_pic.visible = false
      lose_pic.visible = true
      stk:push("<c+:B4B4B4>")
      stk:push(text)
      stk:push("<c->")
    end
    local desc = item:search(L("rb_text"))
    desc.mtf = stk.text
    desc.parent:tune("rb_text")
    if desc.parent.dx < 495 then
      desc.dx = 490
      desc.parent.dx = 495
    end
  end
  if bRebuild then
    g_cloned_battle_history_list:item_clear()
    for i, v in pairs(g_history_data) do
      local item = g_cloned_battle_history_list:item_append()
      item:load_style(cwstr_cell_style_uri, cwstr_history_item)
      set_item_data(item, v)
    end
  else
    local size = g_cloned_battle_history_list.item_count
    if size <= 0 then
      return
    end
    local index = 0
    for i, v in pairs(g_history_data) do
      if size <= index then
        return
      end
      local item = g_cloned_battle_history_list:item_get(index)
      index = index + 1
      set_item_data(item, v)
    end
  end
end
function on_handle_history_list_data(cmd, data)
  local server_stamp = data:get(packet.key.cmn_id).v_int
  g_cloned_battle_history_stamp = server_stamp
  local v_history_data = data:get(packet.key.cmn_dataobj)
  local history_size = v_history_data.size
  if history_size <= 0 then
    return
  end
  g_history_data = {}
  for i = 0, history_size - 1 do
    local history_data = v_history_data:get(i)
    table.insert(g_history_data, history_data)
  end
  fresh_cloned_battle_history_data(true)
end
function on_click_view_award(btn)
  local on_msg_callback = function(msg)
    if msg.result ~= 1 then
      return false
    end
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_UI_ClonedBattle_ToReceiveAward, v)
  end
  local rank_text = sys.format("<c+:17A6DB>%d<c->", g_last_season_award)
  local mtf_text = ui_widget.merge_mtf({rank_id = rank_text}, ui.get_text("clonedbattle|get_award_confirm"))
  local msg = {callback = on_msg_callback, text = mtf_text}
  ui_widget.ui_msg_box.show_common(msg)
end
function on_click_dump_self_data(btn)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_ClonedBattle_DumpSelfData, v)
end
function on_handle_last_season_rank_id(cmd, data)
  local rank_index = data:get(packet.key.ranklist_id).v_int
  g_last_season_award = rank_index
  on_refresh_current_rank_award()
end
function on_handle_to_receive_awardRST(cmd, data)
  if w_main.visible then
    on_refresh_current_rank_award()
  end
  if data:has(packet.key.ranklist_id) ~= true then
    return
  end
  local iRankId = data:get(packet.key.ranklist_id).v_int
  if iRankId <= 0 then
    return
  end
  local text_excel = bo2.gv_text:find(71473)
  if text_excel then
    local data_table = {digit = iRankId}
    local msg = ui_widget.merge_mtf(data_table, text_excel.text)
    ui_tool.note_insert(msg, L("FF00FF00"))
  end
end
function on_refresh_current_rank_award()
  local mb_data_size = bo2.gv_cloned_battle_season_award.size
  local rank_id = g_self_info.ranklist_id
  if rank_id == nil then
    return
  end
  local os_time = ui_main.get_os_time()
  local cur_data = tonumber(os.date("%w", os_time))
  local w_day = 0
  if bo2.IsCoolDownOver(g_season_award_cool_down_id) ~= false and g_last_season_award ~= 0 then
    rank_id = g_last_season_award
  else
    w_day = 1
    rank_id = g_self_info.ranklist_id
  end
  if sys.is_type(rank_id, "number") ~= true or rank_id < 0 then
    rank_id = g_award_max_rank + 1
  end
  for i = 0, mb_data_size - 1 do
    local mb_excel = bo2.gv_cloned_battle_season_award:get(i)
    if mb_excel and rank_id ~= nil and (rank_id <= mb_excel.cur_level or mb_excel.cur_level == -1) then
      local money_label = w_award_info:search(L("money_label"))
      money_label.money = mb_excel.award_money
      if rank_id <= g_award_max_rank then
        money_label.money = money_label.money + (g_award_max_rank - rank_id) * g_season_award_per
      end
      if money_label.money > 1000000 then
        money_label.money = 1000
      end
      money_label.visible = true
      local lb_award_repute = w_award_info:search(L("lb_award_repute"))
      lb_award_repute.text = ui_widget.merge_mtf({
        repute = mb_excel.award_repute
      }, ui.get_text("clonedbattle|rank_repute"))
      lb_award_repute.visible = true
      local get_data_text = function(day, os_time)
        if day == 1 then
          local cur_hour = tonumber(os.date("%H", os_time))
          if cur_hour >= 12 and cur_hour < 22 then
            local cur_min = tonumber(os.date("%M", os_time))
            local get_full_time = function(time_data)
              if time_data < 10 then
                return sys.format(L("0%d"), time_data)
              else
                return sys.format(L("%d"), time_data)
              end
            end
            return ui_widget.merge_mtf({
              hour = get_full_time(21 - cur_hour),
              minute = get_full_time(60 - cur_min)
            }, ui.get_text("clonedbattle|hour_time"))
          else
            return ui.get_text("clonedbattle|one_day")
          end
        elseif day == 2 then
          return ui.get_text("clonedbattle|three_days")
        elseif day >= 3 then
          return ui_widget.merge_mtf({day = day}, ui.get_text("clonedbattle|n_days"))
        end
      end
      if w_day == 0 then
        g_btn_season_award.visible = true
        g_season_award_day.visible = false
        if rank_id > g_award_max_rank then
          w_season_award_text.mtf = ui.get_text("clonedbattle|rank_id_award")
        else
          local rank_text = sys.format("<c+:17A6DB>%d<c->", rank_id)
          local mtf_text = ui_widget.merge_mtf({rank_id = rank_text}, ui.get_text("clonedbattle|rank_id_award"))
          w_season_award_text.mtf = mtf_text
        end
      else
        g_season_award_day.text = get_data_text(w_day, os_time)
        g_season_award_day.tip.text = g_season_award_day.text
        g_season_award_day.visible = true
        g_btn_season_award.visible = false
        w_season_award_text.mtf = ui.get_text("clonedbattle|current_award")
      end
      return
    end
  end
  if rank_id == nil or rank_id > g_award_max_rank or rank_id <= 0 then
    local money_label = w_award_info:search(L("money_label"))
    money_label.visible = false
    g_season_award_day.visible = false
    local lb_award_repute = w_award_info:search(L("lb_award_repute"))
    lb_award_repute.text = ui.get_text("clonedbattle|over_rank_no_award")
    g_btn_season_award.visible = false
    w_season_award_text.mtf = ui.get_text("clonedbattle|current_award")
  end
end
function on_init_cloned_battle()
  OnCleanMemoryData()
end
function on_clear_select_data()
  g_select_item_name = nil
end
function on_select_friend_assist(w_item, only_id)
  local highlight_current = w_item:search("highlight_current")
  if only_id == nil then
    on_clear_select_data()
    highlight_current.visible = false
  else
    if g_select_item_name ~= nil then
      local view = ui_cloned_battle.w_friend_assist_core:search("view")
      local cell = view:search(g_select_item_name)
      if cell ~= nil then
        cell:search("highlight_current").visible = false
      end
    end
    highlight_current.visible = true
    g_select_item_name = w_item.name
    local target_item = w_item:search("name")
    local target_name = target_item.text
    if g_friend_ass_data[tostring(target_name)] == nil then
      local v = sys.variant()
      v:set(packet.key.target_masked_name, target_item.text)
      bo2.send_variant(packet.eCTS_Sociality_ClonedBattle_ViewPlayerComment, v)
    end
  end
end
function on_request_use_friend_assist()
  if g_select_item_name == nil then
    return
  end
  local iOnlyId = 0
  if g_select_item_name ~= nil then
    local view = ui_cloned_battle.w_friend_assist_core:search("view")
    local cell = view:search(g_select_item_name)
    local iData = cell.var:get(packet.key.sociality_tarplayername)
    local iType = cell.var:get(packet.key.sociality_twrelationtype).v_int
    local iOnlyId = iData.v_string
    if cell ~= nil and iOnlyId ~= L("") then
      local v = sys.variant()
      if iType ~= 0 then
        v:set(packet.key.sociality_twrelationtype, iType)
      else
        v:set(packet.key.sociality_tarplayername, iOnlyId)
      end
      if is_friend_assist_knight == false and g_challenge_rank_id ~= 0 then
        v:set(packet.key.ranklist_id, g_challenge_rank_id)
        bo2.send_variant(packet.eCTS_UI_ClonedBattle_Challenge, v)
        g_challenge_rank_id = 0
      else
        v:set(packet.key.knight_pk_npc_cha_id, ui_knight.knight_cha_id)
        v:set(packet.key.knight_pk_npc_lvl, ui_knight.knight_npc_lvl)
        bo2.send_variant(packet.eCTS_Knight_FriendAssist_Confirm, v)
      end
      local view = ui_cloned_battle.w_friend_assist_core:search("view")
      local cell = view:search(g_select_item_name)
      if cell ~= nil then
        cell:search("highlight_current").visible = false
      end
      on_clear_select_data()
      ui_cloned_battle.w_main_friend_assist.visible = false
      ui_cloned_battle.w_main.visible = false
      g_view_cloned_battle = false
    else
      return
    end
  end
end
function on_show_friend_assist_tips(tip)
  if ui_cloned_battle.w_main_friend_assist.visible == false then
    return
  end
  local stk = sys.stack()
  local owner = tip.owner
  local owner_name = owner:search("name")
  if owner_name ~= nil then
    local comment_table = g_friend_ass_data[tostring(owner_name.text)]
    if comment_table ~= nil then
      local flower_text = sys.format("%s%d", ui.get_text("clonedbattle|flower"), comment_table.flower)
      stk_push_line_text(stk, flower_text, nil, nil, "plain")
      local bad_egg_text = sys.format("%s%d", ui.get_text("clonedbattle|bad_egg"), comment_table.bad_egg)
      stk_push_line_text(stk, bad_egg_text, nil, nil, "plain")
      stk:push([[
<tf+:micro>
<sep>
<tf->]])
    end
  end
  stk_push_color_gray(stk)
  stk:push(ui.get_text("clonedbattle|left_cliet_select_friend"))
  stk_push_color_end(stk)
  tip.text = stk.text
  ui_tool.ctip_show(tip.owner, stk, stk_use)
end
function on_mouse_friend_assist_item(w, msg, pos, wheel)
  if msg == ui.mouse_inner then
    local iOnlyId = w.var:get(packet.key.sociality_tarplayername).v_string
    if iOnlyId ~= L("") then
      on_select_friend_assist(w, iOnlyId)
    end
  elseif msg == ui.mouse_outer then
    on_select_friend_assist(w, nil)
  elseif msg == ui.mouse_lbutton_dbl or msg == ui.mouse_lbutton_click then
    local iOnlyId = w.var:get(packet.key.sociality_tarplayername).v_string
    if iOnlyId ~= L("") then
      on_request_use_friend_assist()
    end
  end
end
function set_cell_data(cell, friend_data)
  local highlight_current = cell:search("highlight_current")
  highlight_current.visible = false
  local pic_portrait = cell:search("portrait")
  local label_name = cell:search("name")
  local label_level = cell:search("level")
  local lable_career = cell:search("career")
  if friend_data ~= nil then
    cell.var:set(packet.key.sociality_tarplayername, friend_data.name)
    pic_portrait.visible = true
    pic_portrait.image = ui_im.friend_get_portrait(friend_data)
    local group_id = friend_data.groupid
    label_name.text = friend_data.name
    label_level.text = friend_data.atb[bo2.eAtb_Level]
    if friend_data.thetype == "senior" then
      lable_career.text = ui.get_text("clonedbattle|master")
      cell.var:set(packet.key.sociality_twrelationtype, friend_data.id)
    else
      local pro_excel = bo2.gv_profession_list:find(friend_data.atb[bo2.eAtb_Cha_Profession])
      if pro_excel ~= nil then
        lable_career.text = pro_excel.name
      else
        lable_career.text = ""
      end
    end
    local color
    if friend_data.state == 0 then
      pic_portrait.effect = "gray"
    else
      pic_portrait.effect = ""
    end
    cell.mouse_able = true
    local stk = sys.stack()
    stk_push_color_gray(stk)
    stk:push(ui.get_text("clonedbattle|left_cliet_select_friend"))
    stk_push_color_end(stk)
    cell.tip.text = stk.text
  else
    cell.var:set("id", 0)
    pic_portrait.visible = false
    label_name.text = ""
    label_level.text = ""
    lable_career.text = ""
    cell.mouse_able = false
  end
end
function update_page(page_data)
  on_clear_select_data()
  local page = page_data
  page.count = 1
  local tmp_friend_list = {}
  for i, v in pairs(ui_im.friend_name_list) do
    if v.thetype ~= 0 and v.state ~= 0 then
      table.insert(tmp_friend_list, v)
      page.count = page.count + 1
    end
  end
  local group_sort = function(a, b)
    local priority1 = ui_im.sort_priority[a.thetype] + ui_im.online_priority[a.state] + a.depth
    local priority2 = ui_im.sort_priority[b.thetype] + ui_im.online_priority[b.state] + b.depth
    if priority1 > priority2 then
      return true
    end
    return false
  end
  table.sort(tmp_friend_list, group_sort)
  if page.index > page.count then
    page.index = 0
  end
  local p_idx = math.floor(page.index / n_page_limit)
  local p_cnt = math.floor((page.count + n_page_limit - 1) / n_page_limit)
  ui_widget.ui_stepping.set_page(ui_cloned_battle.w_friend_assist_step, p_idx, p_cnt)
  local p_cur_begin = p_idx * n_page_limit
  local p_cur_end = (p_idx + 1) * n_page_limit
  local count = page.count - 1
  local view = ui_cloned_battle.w_friend_assist_core:search("view")
  local idx = 0
  local page_count = n_page_limit - 1
  for i = 0, page_count do
    local cname = sys.format(cwstr_cell_name, i)
    local cell = view:search(cname)
    idx = page.index + i
    if idx == 0 then
      for i, v in pairs(ui_im.senior_name_list) do
        set_cell_data(cell, v)
        break
      end
    elseif idx < page.count then
      set_cell_data(cell, tmp_friend_list[idx])
    else
      set_cell_data(cell, nil)
    end
  end
  tmp_friend_list = nil
end
function init_friend_assist_data()
  g_friend_ass_data = {}
  local page = {index = 0, count = 0}
  local function on_page_step(var)
    page.index = var.index * n_page_limit
    update_page(page)
  end
  ui_widget.ui_stepping.set_event(ui_cloned_battle.w_friend_assist_step, on_page_step)
  update_page(page)
end
function test_on_visible_get_cloned_battle_data(open)
  local v = sys.variant()
  v:set(packet.key.sociality_personals_type, 1)
  v:set(packet.key.sociality_personals_uiopen, open)
  v:set(packet.key.sociality_personals_data, 1)
  bo2.send_variant(packet.eCTS_Sociality_UISwitch, v)
  local v_data = sys.variant()
  bo2.send_variant(packet.eCTS_UI_ClonedBattle_GetClonedBattleCoolDown, v_data)
end
function on_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
  else
    g_timer_history.suspended = true
    test_on_visible_get_cloned_battle_data(0)
    ui_widget.esc_stk_pop(w)
  end
  ui_handson_teach.test_complate_finish_cloned_battle()
end
function on_friend_assist_esc_stk_visible(w, vis)
  if vis then
    ui_widget.esc_stk_push(w)
    w:move_to_head()
    init_friend_assist_data()
    g_view_cloned_battle = true
  else
    ui_widget.esc_stk_pop(w)
    if g_view_cloned_battle == true and is_friend_assist_knight == false then
      ui_cloned_battle.w_main.visible = true
    end
  end
end
function on_handle_join_rst()
  local on_try_vis_window = function()
    if sys.check(bo2.player) ~= true then
      return
    end
    if w_main.visible == true then
      return
    end
    on_click_vis_window()
    ui_handson_teach.test_complate_hide_cloned_battle()
  end
  bo2.AddTimeEvent(75, on_try_vis_window)
end
function on_handle_view_player_data(cmd, data)
  local player_name = data:get(packet.key.target_masked_name).v_string
  local flower_times = data:get(packet.key.cmn_sender_id).v_int
  local bad_egg_times = data:get(packet.key.cmn_server_cha).v_int
  g_friend_ass_data[tostring(player_name)] = {flower = flower_times, bad_egg = bad_egg_times}
  local view = ui_cloned_battle.w_friend_assist_core:search("view")
  local idx = 0
  for i = 0, n_page_limit - 1 do
    local cell = view:search(sys.format("cell%d", i))
    if sys.check(cell) then
      local cell_text = cell:search("name").text
      if cell_text == player_name then
        on_show_friend_assist_tips(cell.tip)
        break
      end
    end
  end
end
function run()
  w_main.visible = true
end
function on_click_vis_window()
  if sys.check(w_main) ~= true then
    return
  end
  if w_main.visible == true then
    w_main.visible = false
    return true
  end
  on_init_public_info_text()
  g_timer_history.suspended = false
  test_on_visible_get_cloned_battle_data(1)
  refresh_token_time()
  disable_notify_qlink_flicker()
end
local sig_name = "ui_cloned_battle:on_signal_cloned_battle_data"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ClonedBattleSelfData, on_handle_self_data, sig_name)
sig_name = "ui_cloned_battle:on_signal_rank_list_data"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ClonedBattleRankListData, on_handle_rank_list_data, sig_name)
sig_name = "ui_cloned_battle:on_signal_cooldown_token"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_CooldownToken, on_handle_cooldown_token, sig_name)
sig_name = "ui_cloned_battle:on_signal_dirty_data"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ClonedBattleDirtyData, on_handle_dirty_data, sig_name)
sig_name = "ui_cloned_battle:on_signal_last_season_rank_id"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ClonedBattleLastSeasonRankID, on_handle_last_season_rank_id, sig_name)
sig_name = "ui_cloned_battle:on_signal_join_rst"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_ClonedBattle_Join_RST, on_handle_join_rst, sig_name)
sig_name = "ui_cloned_battle:on_handle_history_list_data"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ClonedBattleHistoryData, on_handle_history_list_data, sig_name)
sig_name = "ui_cloned_battle:on_handle_history_stamp"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ClonedBattleHistoryStamp, on_handle_history_stamp, sig_name)
sig_name = "ui_cloned_battle:on_handle_public_info"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ClonedBattlePublicInfo, on_handle_public_info, sig_name)
sig_name = "ui_cloned_battle:on_handle_to_receive_awardRST"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_ClonedBattle_ToReceiveAwardRST, on_handle_to_receive_awardRST, sig_name)
sig_name = "ui_cloned_battle:on_handle_view_player_data"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_ViewPlayerCommentRST, on_handle_view_player_data, sig_name)
ui_packet.recv_wrap_signal_insert(packet.eSTC_ScnObj_CreateFinish, on_cloned_battle_self_enter, "ui_cloned_battle.on_self_enter_finish")
