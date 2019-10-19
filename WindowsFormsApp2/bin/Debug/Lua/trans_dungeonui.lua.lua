remain_time = 0
timer_times = {}
local item_uri = SHARED("$frame/dungeonui/trans_dungeonui.xml")
local item_style = SHARED("per_timer")
local trans_dungeon_time = 600
local least_number = function(src_num, n, direction)
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
local ONE_MINUTE = 60
local ONE_HOUR = 60 * ONE_MINUTE
function get_time(wait_time, text_ui)
  local hour = math.floor(wait_time / ONE_HOUR)
  wait_time = wait_time % ONE_HOUR
  local minute = math.floor(wait_time / ONE_MINUTE)
  local second = wait_time % ONE_MINUTE
  local s = sys.format(ui.get_text(text_ui), least_number(hour, 2), least_number(minute, 2), least_number(second, 2))
  return s
end
function on_transD_timer()
  local main_panel = ui.find_control("$frame:ui_trans_dungeon")
  local g_list = main_panel:search("g_timer_list")
  local size = #timer_times
  for i, v in pairs(timer_times) do
    if v == nil then
      timer_times[i] = nil
    else
      local svar = v.svar
      local client_start_time = svar.client_start_time
      local s = math.floor(sys.dtick(sys.tick(), client_start_time) / 1000)
      local total_time = svar.total_time
      local pasttime = svar.past_time
      remain_time = total_time - pasttime - s
      local cur_time = get_time(remain_time, "wait_list|wait_time_2")
      v:search("time").text = cur_time
      if remain_time <= 0 then
        g_list:item_remove(v.index)
        timer_times[i] = nil
        main_panel.dy = 50 * g_list.item_count
      end
    end
  end
  if #timer_times == 0 then
    main_panel.visible = false
  end
end
function win_on_visible(panel, vis)
end
function com_timerui_on_visible(panel, vis)
  if vis == false then
    gx_transD_timer.suspended = true
    local main_panel = ui.find_control("$frame:ui_trans_dungeon")
    local g_list = main_panel:search("g_timer_list")
    g_list:item_clear()
    timer_times = {}
  else
    local main_panel = ui.find_control("$frame:ui_trans_dungeon")
    local g_list = main_panel:search("g_timer_list")
    g_list:item_clear()
    timer_times = {}
    gx_transD_timer.suspended = false
  end
end
function find_the_same_item(g_list, type)
  for i, v in pairs(timer_times) do
    if v ~= nil then
      local svar = v.svar
      if svar.type ~= nil and svar.type == type then
        return v, i
      end
    end
  end
  return nil
end
function open_one_timer(text, timenum, type, starttime, sendtime, flag)
  local main_panel = ui.find_control("$frame:ui_trans_dungeon")
  local g_list = main_panel:search("g_timer_list")
  if find_the_same_item(g_list, type) ~= nil then
    return
  end
  if main_panel.visible == false then
    main_panel.visible = true
  end
  local count = g_list.item_count
  main_panel.dy = 50 * (count + 1)
  local item = g_list:item_append()
  item:load_style(item_uri, item_style)
  local svar = item.svar
  svar.total_time = timenum
  svar.type = type
  svar.client_start_time = sys.tick()
  svar.start_time = starttime
  local time_past = 0
  if flag == true then
    time_past = 0
  else
    local time_now = ui_main.get_os_time()
    time_past = os.difftime(time_now, starttime)
    if time_past < 0 then
      time_past = 0
    end
  end
  svar.past_time = time_past
  table.insert(timer_times, item)
  item:search("scn_name").text = text
  local cur_time = get_time(timenum - time_past, "wait_list|wait_time_2")
  main_panel:search("time").text = cur_time
  on_transD_timer()
end
function trans_dungeoncd_ui(data)
  remain_time = data:get(packet.key.trans_dungeon_remain_time).v_int
  local scn_id = data:get(packet.key.scn_excel_id).v_int
  local scn_name = bo2.gv_scn_list:find(scn_id).name
  local cur_time = get_time(remain_time, "wait_list|wait_time_2")
  local thename = main_panel:search("scn_name").text
  local type = L("trand_dungeon_fuben")
  local time_v = bo2.get_svrcurtime64()
  local starttime = os.time()
  open_one_timer(thename .. scn_name, remain_time, type, starttime, true)
end
function close_trans_dungeon(data)
  local main_panel = ui.find_control("$frame:ui_trans_dungeon")
  local type = data:get(packet.key.ui_comtimer_type).v_string
  local g_list = main_panel:search("g_timer_list")
  local item, index = find_the_same_item(g_list, type)
  if item ~= nil then
    timer_times[index] = nil
    g_list:item_remove(item.index)
    return
  end
  if #timer_times == 0 then
    main_panel.visible = false
    gx_transD_timer.suspended = true
  end
end
