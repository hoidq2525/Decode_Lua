if rawget(_M, "g_tip_frames") == nil then
  g_tip_frames = {}
  w_tip_top = 0
  g_tip_prev = 0
  w_gain_top = 0
  g_gain_timer = 0
  t_gain_data = {}
  t_gain_queue = {}
  c_gain_limit = 3
  c_gain_delay = 400
  c_gain_wait = 5000
  g_gain_update_tick = 0
end
function on_gain_timer(t)
  local tick = sys.tick()
  local dtick = sys.dtick(tick, g_gain_update_tick)
  if dtick < c_gain_delay then
    return
  end
  if #t_gain_queue == 0 then
    if dtick > c_gain_wait then
      w_gain_top.visible = false
      g_gain_timer.suspended = true
      for i = 1, c_gain_limit do
        t_gain_data[i].view.visible = false
      end
    end
    return
  end
  g_gain_update_tick = tick
  local d = t_gain_data[1]
  table.remove(t_gain_data, 1)
  table.insert(t_gain_data, d)
  local v = d.view
  v:reset()
  v:move_to_head()
  v.visible = true
  local excel_id = t_gain_queue[1]
  table.remove(t_gain_queue, 1)
  d.card.excel_id = excel_id
end
function gain_insert(excel_id)
  if ui_loading.w_top.visible then
    return
  end
  table.insert(t_gain_queue, excel_id)
  while #t_gain_queue > c_gain_limit do
    table.remove(t_gain_queue, 1)
  end
  local off = ui_qbar.w_btn_skill:control_to_window(ui.point(22, 36)) - w_gain_top.size
  w_gain_top.offset = off
  w_gain_top.visible = true
  g_gain_update_tick = sys.tick() - c_gain_delay
  g_gain_timer.suspended = false
  if w_skill.visible == false and w_flicker_skill.visible == false then
    w_flicker_skill.visible = true
  end
end
function on_gain(id, type)
  if not sys.check(w_gain_top) or type == 3 then
    return
  end
  if type == 1 or type == 0 then
    return
  end
  gain_insert(id)
end
c_text_item_file = L("$frame/skill/skill.xml")
function gain_init()
  if sys.check(w_gain_top) then
    return
  end
  ui.insert_skill(on_gain, "ui_skill.on_gain")
  w_gain_top = ui.create_control(ui_main.w_top)
  w_gain_top:load_style(c_text_item_file, "gain_top")
  g_gain_timer = w_gain_top:find_plugin("timer")
  ui.log("g_gain_timer %s.", g_gain_timer)
  local v
  for i = 1, c_gain_limit do
    v = ui.create_control(w_gain_top, "transition_view")
    v:load_style(c_text_item_file, "gain_transition")
    v.visible = false
    local c = v:search("card")
    local d = {view = v, card = c}
    t_gain_data[i] = d
  end
end
