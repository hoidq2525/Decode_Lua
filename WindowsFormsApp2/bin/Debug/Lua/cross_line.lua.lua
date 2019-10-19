local ciRegistOneTimesCost = 200
local g_logout_append_data = {}
local g_test_max = 0
local g_iMinRegistLevel = 30
local g_iDaysPerTimes = 16
function try_add_regist_time(v)
  if g_logout_append_data == nil or g_logout_append_data.bConfirm == nil or g_logout_append_data.bConfirm == false then
    return
  end
  local iCount = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RegistCrossLineCount)
  if g_logout_append_data.regist_times == 0 and iCount == 0 then
    return
  end
  v:set(packet.key.marquee_times, g_logout_append_data.regist_times)
end
function is_money_type_limited()
  return btn_boundedMoney.visible and btn_boundedMoney.check
end
function on_click_limit_money(btn)
  if btn.check == true then
    g_test_max = ib_regist_time.text.v_int
  elseif g_test_max > 0 then
    ib_regist_time.text = g_test_max
    g_test_max = 0
  end
  change_regist_times(nil, ib_regist_time.text)
end
function on_get_award_and_speed_time()
  local check_award_table_vaild = function()
    if g_award_table == nil then
      g_award_table = sys.load_table("$mb/cross_line/cross_line_award.xml")
    end
  end
  function find_award(id)
    check_award_table_vaild()
    if sys.check(g_award_table) then
      return g_award_table:find(id)
    else
      return nil
    end
  end
  local function get_award(id)
    check_award_table_vaild()
    if sys.check(g_award_table) then
      return g_award_table:get(id)
    else
      return nil
    end
  end
  local function get_size_award()
    check_award_table_vaild()
    if sys.check(g_award_table) then
      return g_award_table.size
    else
      return 0
    end
  end
  local has_times = 0
  if sys.check(bo2.player) then
    has_times = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RegistCrossLineCount)
  end
  local _data = {}
  local iTimes = ib_regist_time.text.v_int + has_times
  _data.exp = 0
  if iTimes == 0 then
    _data.day = 0
  else
    _data.day = math.floor(iTimes / g_iDaysPerTimes) + 1
  end
  if iTimes > 0 then
    local iLevel = ui.safe_get_atb(bo2.eAtb_Level)
    local iSize = get_size_award()
    local pExcel
    for i = 0, iSize - 1 do
      local pAwardExcel = get_award(i)
      if sys.check(pAwardExcel) and iLevel >= pAwardExcel.level_begin and (iLevel <= pAwardExcel.level_end or pAwardExcel.level_end == -1) then
        pExcel = pAwardExcel
        break
      end
    end
    if sys.check(pExcel) then
      _data.exp = pExcel.award_exp * iTimes
    end
  end
  return _data
end
function on_confirm()
  w_main.visible = false
  ui_main.goto_choice()
end
function on_cancel()
  if w_main.visible == false then
  else
    w_main.visible = false
  end
end
function on_modify_regist_time_cost()
  local _data = {}
  _data.money = ib_regist_time.text.v_int
  if _data.money <= 0 then
    _data.money = 0
  end
  _data.money = sys.format("<m:%d>", _data.money * ciRegistOneTimesCost)
  rb_cost.mtf = ui_widget.merge_mtf(_data, ui.get_text("cross_line|cost"))
end
function on_modify_award_exp()
  local _data = on_get_award_and_speed_time()
  rb_award_exp.mtf = ui_widget.merge_mtf(_data, ui.get_text("cross_line|cross_line_finish"))
end
function on_plus_times()
  local current_times = ib_regist_time.text.v_int
  if current_times <= 0 then
    ib_regist_time.text = 0
  else
    ib_regist_time.text = current_times - 1
  end
  change_regist_times(nil, ib_regist_time.text)
end
function on_add_times()
  local current_times = ib_regist_time.text.v_int
  ib_regist_time.text = current_times + 1
  change_regist_times(nil, ib_regist_time.text)
end
function change_regist_times(ctrl, text)
  local has_times = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_RegistCrossLineCount)
  local add_times = text.v_int + has_times
  local bBigger = false
  if add_times >= 99 then
    add_times = 99 - has_times
    bBigger = true
  end
  local iCirculatedMoney = bo2.player:get_flag_int32(bo2.eFlagInt32_CirculatedMoney)
  if iCirculatedMoney < add_times * ciRegistOneTimesCost then
    add_times = iCirculatedMoney / ciRegistOneTimesCost
    ib_regist_time.text = math.floor(add_times)
  elseif bBigger == true then
    ib_regist_time.text = add_times
  end
  on_modify_regist_time_cost()
  on_modify_award_exp()
end
function on_esc_stk_visible(w, vis)
  ui_widget.on_esc_stk_visible(w, vis)
  if vis then
    local player = bo2.player
    if sys.check(player) then
      local v = sys.variant()
      local score = ui_personal.ui_equip.make_dmg_score(player) + ui_personal.ui_equip.make_def_score(player)
      v:set(packet.key.gs_score, score)
      local camp_id = player:get_atb(bo2.eAtb_Camp)
      v:set(packet.key.camp_id, camp_id)
      bo2.send_variant(packet.eCTS_Sociality_CrossLineGetGSRank, v)
    end
    if sys.check(rb_rank) then
      rb_rank.mtf = ui_widget.merge_mtf({
        rank = L("??")
      }, ui.get_text("cross_line|cross_line_rank"))
    end
  else
  end
end
function run()
end
function runf()
  w_main.visible = true
end
function on_handle_gs_rank(cmd, data)
  local iRank = data:get(packet.key.ranklist_id).v_int
  if sys.check(rb_rank) then
    rb_rank.mtf = ui_widget.merge_mtf({rank = iRank}, ui.get_text("cross_line|cross_line_rank"))
  end
end
local sig_name = "ui_cross_line:on_handle_gs_rank"
ui_packet.recv_wrap_signal_insert(packet.eSTC_Sociality_CrossLineGSRank, on_handle_gs_rank, sig_name)
local ciCrossLineBattleCD = 30039
function on_handle_cooldown_token(cmd, data)
  if data:has(packet.key.cmn_type) ~= true then
    return
  end
  local iExcelId = data:get(packet.key.cooldown_id).v_int
  if iExcelId ~= ciCrossLineBattleCD then
    return
  end
  ui_reciprocal.del_reciproca("cross_line")
  local span = data:get(packet.key.cooldown_passSec).v_int
  local keep = data:get(packet.key.cooldown_keepSec).v_int
  if span > keep then
    return
  end
  local insert_sub = {}
  insert_sub.time = keep - span
  insert_sub.name = ui.get_text("cross_line|cross_line_cd_name")
  insert_sub.close = true
  insert_sub.callback = on_time_event
  ui_reciprocal.add_reciproca("cross_line", insert_sub)
end
sig_name = "ui_cross_line:on_signal_cooldown_token"
ui_packet.recv_wrap_signal_insert(packet.eSTC_UI_CooldownToken, on_handle_cooldown_token, sig_name)
