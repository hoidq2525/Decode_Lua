local g_left_time = 0
local g_total_time = 0
local g_has_award = false
local g_start_time = 0
local time_text = ui.get_text("timeaward|time_text")
local online_award = ui.get_text("timeaward|online_award")
local online_time_award = ui.get_text("timeaward|online_time_award")
local award_tip = ui.get_text("timeaward|award_tip")
local award_included = ui.get_text("timeaward|award_included")
local no_award = ui.get_text("timeaward|no_award")
local lclick_to_get = ui.get_text("timeaward|lclick_to_get")
local ldrag_to_move = ui.get_text("timeaward|ldrag_to_move")
local award_amount = ui.get_text("timeaward|award_amount")
local no_award_warning = ui.get_text("timeaward|no_award_warning")
local award_in_bag = ui.get_text("timeaward|award_in_bag")
local rcv_finish = ui.get_text("timeaward|rcv_finish")
local award_reset = ui.get_text("timeaward|award_reset")
local t_limitlevel = ui.get_text("timeaward|limitlevel")
local t_awardover = ui.get_text("timeaward|awardover")
local t_newday = ui.get_text("timeaward|newday")
local t_nextlevel = ui.get_text("timeaward|nextlevel")
function on_init()
  g_left_time = 0
  g_total_time = 0
  w_flicker2.visible = false
  w_flicker2.suspended = true
  g_has_award = false
  g_start_time = 0
end
function on_timer()
  g_left_time = g_left_time - 1
  if g_left_time < 0 then
    g_left_time = 0
  end
end
function get_time_text_by_second(second)
  local wstr_text
  local iHour = math.floor(second / 3600)
  local v = math.fmod(second, 3600)
  local iMinute = math.floor(v / 60)
  local iSecond = math.fmod(v, 60)
  local time_data = {}
  iMinute = iMinute + iHour * 60
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
  wstr_text = ui_widget.merge_mtf(time_data, ui.get_text("timeaward|time_text"))
  return wstr_text
end
function on_gift_btn(btn, msg, pos, wheel)
  if msg == ui.mouse_inner then
    local v = sys.variant()
    bo2.send_variant(packet.eCTS_UI_SyncTime, v)
  end
end
function on_visible(ctrl, vis)
  if vis then
    gx_window.visible = false
  end
end
function on_get_server_time(cmd, data)
  local cur_time = data:get(packet.key.cmn_id).v_int
  g_left_time = g_total_time - (cur_time - g_start_time)
end
function on_card_tip_show(tip)
  local card = tip.owner
  local stk = sys.mtf_stack()
  local w_time
  local p_lev = bo2.player:get_atb(bo2.eAtb_Level)
  if p_lev < 20 then
    ui_tool.ctip_push_text(stk, t_limitlevel, ui_tool.cs_tip_color_yellow)
    ui_tool.ctip_show(card, stk)
    return
  end
  local cur_index = bo2.player:get_flag_int32(bo2.ePlayerFlagInt32_CurAwardIndex)
  if cur_index >= 6 then
    ui_tool.ctip_push_text(stk, t_awardover, ui_tool.cs_tip_color_yellow)
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, t_newday, "FF6600")
    ui_tool.ctip_show(card, stk)
    return
  end
  local is_award = bo2.player:get_flag_int16(bo2.ePlayerFlagInt16_TimeAward_Today1)
  local cur_excel = bo2.gv_time_award:get(cur_index)
  if cur_excel ~= nil then
    if g_has_award then
      w_time = ui.get_text("timeaward|lingqu")
    elseif is_award == 1 then
      w_time = ui.get_text("timeaward|lingqu")
      g_has_award = true
    else
      w_time = get_time_text_by_second(g_left_time)
    end
    ui_tool.ctip_push_text(stk, w_time, ui_tool.cs_tip_color_yellow)
    ui_tool.ctip_push_newline(stk)
    local item = ui.item_get_excel(cur_excel.item)
    stk:raw_push("<img:$icon/item/" .. item.icon .. ".png*20,20>")
    ui_tool.ctip_push_text(stk, item.name, item.plootlevel.color)
  end
  local next_excel = bo2.gv_time_award:get(cur_index + 1)
  if next_excel ~= nil then
    ui_tool.ctip_push_newline(stk)
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, t_nextlevel, ui_tool.cs_tip_color_yellow)
    ui_tool.ctip_push_newline(stk)
    local item = ui.item_get_excel(next_excel.item)
    stk:raw_push("<img:$icon/item/" .. item.icon .. ".png*20,20>")
    ui_tool.ctip_push_text(stk, item.name, item.plootlevel.color)
  end
  if g_has_award or is_award == 1 then
    ui_tool.ctip_push_sep(stk)
    ui_tool.ctip_push_text(stk, lclick_to_get, "FF6600")
  end
  ui_tool.ctip_show(card, stk)
end
function on_card_mouse(card, msg, pos, wheel)
end
function on_has_award(cmd, data)
  w_flicker2.visible = true
  w_flicker2.suspended = false
  m_timer.suspended = true
  g_left_time = 0
  g_has_award = true
  g_start_time = 0
end
function on_init_data(cmd, data)
  local t = data:get(packet.key.cmn_index).v_int
  g_start_time = t
  local o = ui_main.get_os_time() - t
  local time = data:get(packet.key.cmn_id).v_int
  g_left_time = time
  g_total_time = time
  if time < 1 then
    g_left_time = 0
    g_total_time = 0
  end
  m_timer.suspended = false
end
function on_get_award(btn)
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_GetTimeAward, v)
end
function on_get_award_ack(cmd, data)
  w_flicker2.visible = false
  w_flicker2.suspended = true
  g_has_award = false
end
function on_today_over(cmd, data)
  w_flicker2.visible = false
  w_flicker2.suspended = true
  m_timer.suspended = true
  g_left_time = 0
  g_total_time = 0
  g_has_award = false
  g_start_time = 0
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_timeaward.packet_handle"
reg(packet.eSTC_UI_TodayAwardOver, on_today_over, sig)
reg(packet.eSTC_UI_TimeAwardOver, on_has_award, sig)
reg(packet.eSTC_UI_GetTimeAward, on_get_award_ack, sig)
reg(packet.eSTC_UI_OLTimeInit, on_init_data, sig)
reg(packet.eSTC_UI_SyncTime, on_get_server_time, sig)
