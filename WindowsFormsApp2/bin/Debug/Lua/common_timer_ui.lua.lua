local reg = ui_packet.game_recv_signal_insert
local sig = "ui_dungeonui.ui_common_timer.packet_handle"
function show_timer_ui(data)
  local info_id = data:get(packet.key.ui_comtimer_info).v_int
  local time = data:get(packet.key.ui_comtimer_time).v_int
  local type = data:get(packet.key.ui_comtimer_type).v_string
  local starttime = data:get(packet.key.ui_comtimer_starttime).v_int
  local flag = data:has(packet.key.cmn_system_flag)
  if info_id == 0 then
    return
  end
  local info = bo2.gv_text:find(info_id).text
  ui_dungeonui.open_one_timer(info, time, type, starttime, flag)
  if type == L("CrossLineTrans") then
    ui_minimap.set_leave_help_visible(true)
  end
end
function open_common_timerui(cmd, data)
  if data:has("info") == true then
    local v_data = data:get(L("info"))
    for i = 0, v_data.size - 1 do
      local tar = v_data:get(i)
      show_timer_ui(tar)
    end
  else
    show_timer_ui(data)
  end
end
reg(packet.eSTC_UI_ComTimer_Open, open_common_timerui, sig)
function close_common_timerui(cmd, data)
  local main_panel = ui_dungeonui.gx_trans_dungeon
  if main_panel.visible ~= false then
    local type = data:get(packet.key.ui_comtimer_type).v_string
    local g_list = main_panel:search("g_timer_list")
    local item, index = ui_dungeonui.find_the_same_item(g_list, type)
    if item ~= nil then
      ui_dungeonui.timer_times[index] = nil
      g_list:item_remove(item.index)
      return
    end
    if #ui_dungeonui.timer_times == 0 then
      main_panel.visible = false
      local timer = main_panel.timer
      timer.suspended = true
    end
  end
end
reg(packet.eSTC_UI_ComTimer_Close, close_common_timerui, sig)
