local second = 100
local tick_update
local sch_list = {
  type = "type",
  name = "name",
  starts = "start",
  ends = "end",
  cd = "cd"
}
local tree_root_name = {
  [1] = ui.get_text("guild|tip_cmn26"),
  [2] = ui.get_text("guild|tip_cmn27"),
  [3] = nil,
  [4] = ui.get_text("guild|guild_schedule_type_enemy")
}
function f(x)
  local text = ""
  if x > 9 then
    text = x
  else
    text = "0" .. x
  end
  return text
end
function time_chg(sec)
  local hh, mm, ss
  ss = sec % 60
  sec = (sec - ss) / 60
  mm = sec % 60
  hh = (sec - mm) / 60
  return f(hh) .. ":" .. f(mm) .. ":" .. f(ss)
end
function date_chg(tms)
  local f = function(x)
    local text = ""
    if x > 9 then
      text = x
    else
      text = "0" .. x
    end
    return text
  end
  return tms.year .. "/" .. tms.month .. "/" .. tms.day .. " " .. f(tms.hour) .. ":" .. f(tms.min) .. ":" .. f(tms.sec)
end
function on_schedule_show(vis)
  ui_widget.on_esc_stk_visible(vis)
end
function on_timer()
  if tick_update == nil then
    if ui_info_tip.find_item(ui_info_tip.info_tip_inc.schedule_info) == false then
      ui_info_tip.schedule_cd.sch_cd.visible = false
    end
    return
  end
  local ds = math.floor(sys.dtick(sys.tick(), tick_update) / 1000)
  ds = second - ds
  sch_cd:search("s_cd"):search("value_text").text = time_chg(ds)
  if ds == 0 then
    ui_info_tip.on_click_del_msg(ui_info_tip.info_tip_inc.schedule_info)
    ui_info_tip.schedule_cd.sch_cd.visible = false
    tick_update = nil
  end
end
function on_data_init(data)
  local quest_id = data:get(packet.key.quest_id).v_int
  local duration
  for i = 0, bo2.gv_guild_schedule.size - 1 do
    local line = bo2.gv_guild_schedule:get(i)
    if line.id == quest_id then
      sch_list.name = line.name
      sch_list.type = tree_root_name[line.type]
      duration = line.time
    end
  end
  local function make_time()
    local rsv_time = data:get(packet.key.guild_schedule_reservetime).v_int + data:get(packet.key.guild_schedule_opentime).v_int
    sch_list.starts = date_chg(os.date("*t", rsv_time))
    rsv_time = rsv_time + duration
    sch_list.ends = date_chg(os.date("*t", rsv_time))
    second = rsv_time - ui_main.get_os_time()
    tick_update = sys.tick()
  end
  sys.fp_pcall(make_time)
end
function OpenSchedule(data)
  on_data_init(data)
  sch_cd:search("s_type"):search("value_text").text = sch_list.type
  sch_cd:search("s_name"):search("value_text").text = sch_list.name
  sch_cd:search("s_start"):search("value_text").text = sch_list.starts
  sch_cd:search("s_end"):search("value_text").text = sch_list.ends
  ui_info_tip.on_click_add_msg(ui_info_tip.info_tip_inc.schedule_info)
end
function CloseSchedule(data)
  ui_info_tip.on_click_del_msg(ui_info_tip.info_tip_inc.schedule_info)
  ui_info_tip.schedule_cd.sch_cd.visible = false
end
function CheckSchedule(cmd, data)
  local state = data:get(packet.key.cmn_state).v_int
  if state == bo2.eScheduleState_Done then
    OpenSchedule(data)
  elseif state == bo2.eScheduleState_End then
    CloseSchedule(data)
  end
end
local reg = ui_packet.game_recv_signal_insert
local sig = "ui_info_tip.schedule_cd:on_signal"
reg(packet.eSTC_Guild_Schedule, CheckSchedule, sig)
