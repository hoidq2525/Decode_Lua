local g_event_mgr = {}
local monitor_panel = {}
local pic_succ = {}
local event_over_t = {}
local stamp_ani_t = {}
timer_fn = nil
mid_timer_fn = nil
pic_succ[true] = SHARED("$image/rand_event/successr.png|0,0,53,40")
pic_succ[false] = SHARED("$image/rand_event/failr.png|0,0,53,40")
function init_timer()
  local stamp_animation_time = 50
  local stamp_animation_step = 0
  local curr_stamp_info
  local stamp_animation = ui_monitor:search("stamp_animation")
  local pic_stamp_ani = ui_monitor:search("pic_stamp_ani")
  return function()
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
    stamp_animation.margin = ui.rect(0, 9 + 46 * curr_stamp_info[1], 22 + 44 * percent, 0)
    if stamp_animation_step >= stamp_animation_time then
      curr_stamp_info[3].pic_stamp.visible = true
      pic_stamp_ani.visible = false
      stamp_animation_step = 0
      curr_stamp_info = nil
      return true
    end
  end
end
function init_mid_timer()
  local step = 1
  local eventcount = 0
  local event = {}
  for _, v in pairs(g_event_mgr.event) do
    event[v.idx] = v
    eventcount = eventcount + 1
  end
  local alpha = 10
  local bstay = 10
  local bmid = true
  local lbl_event_show = w_middle:search("lbl_event_show")
  local flicker = monitor_panel[1].flicker
  w_middle.visible = true
  lbl_event_show.text = event[1].short_desc
  return function()
    if 1 == step or 2 == step then
      if bstay > 0 then
        bstay = bstay - 1
        return
      end
      alpha = alpha - 1
      lbl_fader.alpha = alpha / 10
    elseif 3 == step or 4 == step then
      if bstay > 0 then
        bstay = bstay - 1
        return
      end
      alpha = alpha - 2
      flicker.alpha = alpha / 10
    else
      mid_timer.suspended = true
    end
    if alpha <= 0 then
      step = step + (eventcount >= 2 and 1 or 2)
      bmid = step <= 2
      alpha = 10
      bstay = bmid and 10 or 3
      w_middle.visible = bmid
      if 2 == step then
        lbl_event_show.text = event[2].short_desc
        lbl_fader.alpha = alpha / 10
      end
      if 3 == step then
        flicker.visible = true
      end
      if 4 == step then
        flicker.visible = false
        flicker = monitor_panel[2].flicker
        flicker.visible = true
      end
    end
  end
end
function init_panel()
  local item1 = ui_monitor:search("item1")
  local item2 = ui_monitor:search("item2")
  monitor_panel[1] = {
    item_panel = item1,
    lb_event_name = item1:search("lb_event_name"),
    lb_event_prog = item1:search("lb_event_prog"),
    pic_stamp = item1:search("pic_succ"),
    flicker = item1:search("fig_flick")
  }
  monitor_panel[2] = {
    item_panel = item2,
    lb_event_name = item2:search("lb_event_name"),
    lb_event_prog = item2:search("lb_event_prog"),
    pic_stamp = item2:search("pic_succ"),
    flicker = item2:search("fig_flick")
  }
  for _, v in pairs(g_event_mgr.event) do
    local item = monitor_panel[v.idx]
    item.lb_event_name.text = v.short_desc
    item.pic_stamp.visible = false
    local event_prog = item.lb_event_prog
    if 1 < math.abs(v.monistyle) then
      event_prog.text = sys.format("%d/%d", v.monidata, math.abs(v.monistyle))
      event_prog.visible = true
    else
      event_prog.text = ""
      event_prog.visible = false
    end
    item.item_panel.visible = true
  end
end
function clear_panel()
  for _, v in pairs(g_event_mgr.event) do
    local item = monitor_panel[v.idx]
    item.lb_event_name.text = ""
    item.pic_stamp.visible = false
    local event_prog = item.lb_event_prog
    event_prog.text = ""
    event_prog.visible = false
    item.item_panel.visible = false
  end
end
function on_event_show()
  ui_quest.ui_tracing.on_show_knightevent_info()
  ui_rand_event.identify_event()
  g_event_mgr = ui_rand_event.g_event_mgr
  init_panel()
  timer_fn = init_timer()
  bo2.AddTimeEvent(150, show_event_ani)
end
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
  local bActive, bSuccess, bOver = ui_rand_event.GetStateDetail(state)
  local idx = eventInfo.idx
  local item = monitor_panel[idx]
  if bOver then
    if event_over_t[idx] then
      return
    end
    table.insert(stamp_ani_t, {
      idx,
      bSuccess,
      item
    })
    event_over_t[idx] = true
    item.pic_stamp.image = pic_succ[bSuccess]
    item.lb_event_prog.visible = false
    g_timer.suspended = false
  else
    if eventInfo.monistyle > 1 and eventInfo.monistyle > eventInfo.monidata then
      eventInfo.monidata = step
      item.lb_event_prog.text = sys.format("%d/%d", eventInfo.monidata, math.abs(eventInfo.monistyle))
    elseif eventInfo.monistyle < -1 and eventInfo.monidata > 0 then
      eventInfo.monidata = math.abs(eventInfo.monistyle) - step
      item.lb_event_prog.text = sys.format("%d/%d", eventInfo.monidata, math.abs(eventInfo.monistyle))
    end
    item.lb_event_prog.visible = true
    item.pic_stamp.visible = false
    event_over_t[eventInfo.idx] = false
  end
end
function close_monitor()
  clear_panel()
  g_event_mgr = {}
  event_over_t = {}
  w_middle.visible = false
  ui_quest.ui_tracing.on_close_knightevent_info()
end
function show_event_ani()
  mid_timer_fn = init_mid_timer()
  mid_timer.suspended = false
end
function on_timer()
  timer_fn()
end
function on_mid_timer()
  mid_timer_fn()
end
function update_highlight(item)
  item:search("fig_highlight").visible = item.inner_hover
end
function on_cmn_item_mouse(item, msg)
  if msg == ui.mouse_enter or msg == ui.mouse_leave or msg == ui.mouse_inner or msg == ui.mouse_outer then
    update_highlight(item)
  end
end
function on_tip_make(tip)
  local g_event_sort_idx = ui_rand_event.g_event_sort_idx
  local item_panel = tip.owner
  local event_id = g_event_sort_idx[tonumber(string.sub(tostring(item_panel.name), 5))]
  local event_info = g_event_mgr.event[event_id]
  if nil == event_info then
    return
  end
  local tip_title = event_info.name
  if nil == tip_title then
    return
  end
  local tip_content = event_info.desc
  if nil == tip_content then
    return
  end
  local stk = sys.mtf_stack()
  ui_tool.ctip_push_text(stk, tip_title, ui_tool.cs_tip_color_green)
  ui_tool.ctip_push_sep(stk)
  stk:raw_push(tip_content)
  ui_tool.ctip_push_sep(stk)
  local tmoney
  if 0 == event_info.money_type then
    tmoney = sys.format("<m:%d>", event_info.money_base + event_info.money_level)
  else
    tmoney = sys.format("<bm:%d>", event_info.money_base + event_info.money_level)
  end
  local v = sys.variant()
  v:set("tip_money", tmoney)
  v:set("tip_exp", tostring(event_info.exp_base + event_info.exp_level))
  stk:raw_format(sys.mtf_merge(v, ui.get_text("scncopy|tip_money")))
  stk:raw_format(sys.mtf_merge(v, ui.get_text("scncopy|tip_exp")))
  local item_line = bo2.gv_item_list:find(event_info.item_type)
  if nil ~= item_line then
    v:set("tip_icon", tostring(item_line.icon))
    v:set("tip_tool", event_info.item_count)
    stk:raw_format(sys.mtf_merge(v, ui.get_text("scncopy|tip_tool")))
  end
  ui_tool.ctip_show(tip.owner, stk, nil)
end
