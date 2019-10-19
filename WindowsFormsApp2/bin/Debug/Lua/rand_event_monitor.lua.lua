local g_event_mgr
local pic_succ = {}
pic_succ[true] = SHARED("$image/rand_event/successr.png|0,0,53,40")
pic_succ[false] = SHARED("$image/rand_event/failr.png|0,0,53,40")
local stamp_idx_for_timer
local stamp_animation_time = 50
local stamp_animation_step = 0
local stamp_animation, pic_stamp_ani
local stamp_ani_t = {}
local event_over_t = {}
function on_event_chg(data)
  if nil == g_event_mgr then
    return
  end
  local eventID = data:get(packet.key.rand_event_info_id).v_int
  local state = data:get(packet.key.rand_event_info_state).v_int
  local step = data:get(packet.key.rand_event_info_step).v_int
  local eventInfo = g_event_mgr.event[eventID]
  if nil == eventInfo then
    return
  end
  eventInfo.state = state
  local bActive, bSuccess, bOver = ui_rand_event.GetStateDetail(eventInfo.state)
  local item_panel = ui_quest.ui_tracing.panel_rand_event:search("item" .. eventInfo.idx)
  if bOver then
    if event_over_t[eventInfo.idx] then
      return
    end
    event_over_t[eventInfo.idx] = true
    local stamp_info_t = {}
    stamp_info_t[1] = eventInfo.idx
    stamp_info_t[2] = bSuccess
    stamp_info_t[3] = item_panel
    table.insert(stamp_ani_t, stamp_info_t)
    item_panel:search("pic_succ").image = pic_succ[bSuccess]
    item_panel:search("lb_event_prog").visible = false
    g_timer.suspended = false
  else
    if 1 < eventInfo.monistyle and eventInfo.monistyle > eventInfo.monidata then
      eventInfo.monidata = step
      item_panel:search("lb_event_prog").text = sys.format("%d/%d", eventInfo.monidata, math.abs(eventInfo.monistyle))
    elseif eventInfo.monistyle < -1 and eventInfo.monidata > 0 then
      eventInfo.monidata = math.abs(eventInfo.monistyle) - step
      item_panel:search("lb_event_prog").text = sys.format("%d/%d", eventInfo.monidata, math.abs(eventInfo.monistyle))
    end
    item_panel:search("lb_event_prog").visible = true
    item_panel:search("pic_succ").visible = false
    event_over_t[eventInfo.idx] = false
  end
end
function refresh_item(eventID)
  if nil == g_event_mgr then
    return
  end
  local eventInfo = g_event_mgr.event[eventID]
  if nil == eventInfo then
    return
  end
  local bActive, bSuccess, bOver = ui_rand_event.GetStateDetail(eventInfo.state)
  local item_panel = ui_quest.ui_tracing.panel_rand_event:search("item" .. eventInfo.idx)
  if bOver then
    local stamp_info_t = {}
    stamp_info_t[1] = eventInfo.idx
    stamp_info_t[2] = bSuccess
    stamp_info_t[3] = item_panel
    table.insert(stamp_ani_t, stamp_info_t)
    item_panel:search("pic_succ").image = pic_succ[bSuccess]
    item_panel:search("lb_event_prog").visible = false
    g_timer.suspended = false
  else
    if 1 < eventInfo.monistyle and eventInfo.monistyle > eventInfo.monidata then
      item_panel:search("lb_event_prog").text = sys.format("%d/%d", eventInfo.monidata, math.abs(eventInfo.monistyle))
    elseif eventInfo.monistyle < -1 and eventInfo.monidata > 0 then
      item_panel:search("lb_event_prog").text = sys.format("%d/%d", eventInfo.monidata, math.abs(eventInfo.monistyle))
    end
    item_panel:search("lb_event_prog").visible = true
    item_panel:search("pic_succ").visible = false
  end
end
function refresh_monitor()
  local function refresh_ui()
    if nil == g_event_mgr then
      return
    end
    local eventSet = g_event_mgr.event
    for eventID, _ in pairs(eventSet) do
      refresh_item(eventID)
    end
  end
  bo2.AddTimeEvent(25, refresh_ui)
end
function on_timer()
  time_stamp_animation()
end
function time_stamp_animation()
  if nil == curr_stamp_info then
    curr_stamp_info = table.remove(stamp_ani_t)
    if nil == curr_stamp_info then
      g_timer.suspended = true
      return true
    end
    pic_stamp_ani.image = pic_succ[curr_stamp_info[2]]
    pic_stamp_ani.visible = true
    stamp_animation_step = 0
  end
  if stamp_animation_step >= stamp_animation_time then
    return true
  end
  stamp_animation_step = stamp_animation_step + 1
  local percent = 1 - stamp_animation_step / stamp_animation_time
  stamp_animation.dx = 53 + 53 * percent / 2
  stamp_animation.dy = 40 + 40 * percent / 2
  stamp_animation.margin = ui.rect(0, 55 + 46 * curr_stamp_info[1], 22 + 44 * percent, 0)
  if stamp_animation_step >= stamp_animation_time then
    curr_stamp_info[3]:search("pic_succ").visible = true
    pic_stamp_ani.visible = false
    stamp_animation_step = 0
    curr_stamp_info = nil
    return true
  end
end
function on_uiboard(data)
  if nil == g_event_mgr then
    return
  end
  local vEventComp = data:get(packet.key.rand_event_ui_state)
  local eventSet = g_event_mgr.event
  for eventID, eventInfo in pairs(eventSet) do
    if nil ~= eventInfo then
      local bActive, bSuccess, bOver = ui_rand_event.GetStateDetail(eventInfo.state)
      local item_panel = ui_quest.ui_tracing.panel_rand_event:search("item" .. eventInfo.idx)
      if bOver then
        item_panel:search("pic_succ").image = pic_succ[bSuccess]
        item_panel:search("pic_succ").visible = true
        item_panel:search("lb_event_prog").visible = false
      else
        eventInfo.monidata = vEventComp:get(eventID).v_int
        if eventInfo.monistyle > 1 and eventInfo.monistyle > eventInfo.monidata then
          item_panel:search("lb_event_prog").text = sys.format("%d/%d", eventInfo.monidata, math.abs(eventInfo.monistyle))
        elseif eventInfo.monistyle < -1 and eventInfo.monidata > 0 then
          item_panel:search("lb_event_prog").text = sys.format("%d/%d", eventInfo.monidata, math.abs(eventInfo.monistyle))
        end
      end
    end
  end
end
function on_monitor_visible(panel, bool)
  if bool then
  elseif nil ~= g_event_mgr then
    ui_rand_event.b_system_on = false
    g_event_mgr = nil
    ui_quest.ui_tracing.on_close_randevent_info()
    ui_widget.on_leavescn_stk_visible(panel, bool)
  end
end
function show_monitor(bFirstTime)
  ui_quest.ui_tracing.on_show_randevent_info()
  g_event_mgr = ui_rand_event.g_event_mgr
  init_monitor()
  if bFirstTime then
    refresh_monitor()
  end
end
function pre_init_monitor()
  g_event_mgr = ui_rand_event.g_event_mgr
  init_monitor()
end
function close_monitor()
  ui_rand_event.b_system_on = false
  ui_quest.ui_tracing.on_close_randevent_info()
  g_event_mgr = nil
  local monitor_panel = ui_quest.ui_tracing.panel_rand_event
  if nil == monitor_panel then
    return
  end
  for i = 1, 6 do
    local item_panel = monitor_panel:search("item" .. i)
    if nil ~= item_panel then
      item_panel.visible = false
    end
  end
  event_over_t = {}
  ui_quest.ui_tracing.panel_rand_event:search("lb_progress").text = sys.format("%d%%", 0)
  ui_quest.ui_tracing.panel_rand_event:search("progress_inner").dx = 0
  ui_quest.ui_tracing.update_show_randevent_info()
end
function on_runtime_info(data)
  local kill = data:get(packet.key.dungeon_runtime_info_kill).v_int
  local dungeon_info_excel_id = data:get(packet.key.dungeon_info_excel_id).v_int
  local dungeon_info_excel = bo2.gv_dungeon_define:find(dungeon_info_excel_id)
  if nil == dungeon_info_excel then
    dungeon_info_excel = bo2.gv_dungeon_define:find(1)
  end
  local complete = math.floor(kill * 100 / dungeon_info_excel._Kill_Max)
  ui_quest.ui_tracing.panel_rand_event:search("lb_progress").text = sys.format("%d%%", complete)
  ui_quest.ui_tracing.panel_rand_event:search("progress_inner").dx = math.floor(1.74 * complete)
  ui_quest.ui_tracing.update_show_randevent_info()
end
function on_dungeon_complete_chg(data)
  local completation = data:get(packet.key.dungeon_player_completation).v_int
  ui_quest.ui_tracing.panel_rand_event:search("lb_progress").text = sys.format("%d%%", completation)
  ui_quest.ui_tracing.panel_rand_event:search("progress_inner").dx = math.floor(1.74 * completation)
  ui_quest.ui_tracing.update_show_randevent_info()
end
function init_monitor()
  local monitor_panel = ui_quest.ui_tracing.panel_rand_event
  if nil == monitor_panel then
    return
  end
  local event = g_event_mgr.event
  for _, v in pairs(event) do
    local item_panel = monitor_panel:search("item" .. v.idx)
    local diff
    if 0 == v.difficulty then
      diff = ui.get_text("scncopy|hard")
    elseif 1 == v.difficulty then
      diff = ui.get_text("scncopy|normal")
    else
      diff = ui.get_text("scncopy|easy")
    end
    item_panel:search("lb_event_name").text = sys.format(ui.get_text("scncopy|randevent_name"), v.name, diff)
    item_panel:search("lb_event_desc").text = v.short_desc
    item_panel:search("pic_succ").visible = false
    item_panel:search("lb_event_prog").text = ""
    if 1 < math.abs(v.monistyle) then
      item_panel:search("lb_event_prog").text = sys.format("%d/%d", v.monidata, math.abs(v.monistyle))
      item_panel:search("lb_event_prog").visible = true
    end
    item_panel.visible = true
  end
  stamp_animation = ui_quest.ui_tracing.panel_rand_event:search("stamp_animation")
  pic_stamp_ani = ui_quest.ui_tracing.panel_rand_event:search("pic_stamp_ani")
end
function update_highlight(item)
  item:search("fig_highlight").visible = item.inner_hover
end
function on_cmn_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_highlight(item)
  end
end
