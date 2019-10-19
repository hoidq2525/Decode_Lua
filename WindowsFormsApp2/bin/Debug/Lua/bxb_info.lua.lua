local use_time = 0
local client_start_time = 0
local past_time = 0
function bingxuebao_visible()
  remain_time_label.visible = false
  time_label.visible = true
  kill_label.visible = true
  skill_label.visible = true
  dead_label.visible = false
  timer.suspended = false
  remain_timer.suspended = true
  ui_quest.ui_tracing.on_show_dungeon_runtime_info()
end
function time_update(t)
  if t == nil then
    local s = math.floor(sys.dtick(sys.tick(), client_start_time) / 1000)
    use_time = past_time + s
  else
    use_time = t
  end
  local h, m, s, v
  h = math.floor(use_time / 3600)
  v = math.fmod(use_time, 3600)
  m = math.floor(v / 60)
  s = math.fmod(v, 60)
  local ref_time = {
    _h = h,
    _m = m,
    _s = s
  }
  time_label:search("rb_text").mtf = ui_widget.merge_mtf(ref_time, sys.format(ui.get_text("dungeonui|dungeon_time")))
end
function bingxuebao_info(data)
  bingxuebao_visible()
  local tb1 = {count = 0}
  kill_label:search("rb_text").mtf = ui_widget.merge_mtf(tb1, sys.format(ui.get_text("dungeonui|bxb_bingkuai")))
  local tb2 = {count = 0}
  skill_label:search("rb_text").mtf = ui_widget.merge_mtf(tb2, sys.format(ui.get_text("dungeonui|bxb_yaoguai")))
  local server_time = data:get(packet.key.ui_comtimer_starttime).v_int
  local client_time = ui_main.get_os_time()
  client_start_time = sys.tick()
  local interval = client_time - server_time
  if interval < 0 then
    interval = 0
  end
  past_time = interval
  time_update(interval)
end
function update_bxb_num(cmd, data)
  local bingkuai_num = data:get(packet.key.bxb_bingkuai_num).v_int
  local tb1 = {count = bingkuai_num}
  kill_label:search("rb_text").mtf = ui_widget.merge_mtf(tb1, sys.format(ui.get_text("dungeonui|bxb_bingkuai")))
  local yaomo_num = data:get(packet.key.bxb_yaomo_num).v_int
  local tb2 = {count = yaomo_num}
  skill_label:search("rb_text").mtf = ui_widget.merge_mtf(tb2, sys.format(ui.get_text("dungeonui|bxb_yaoguai")))
  local server_start_time = data:get(packet.key.ui_comtimer_starttime).v_int
  local server_cur_time = data:get(packet.key.ui_comtimer_time).v_int
  local interval = server_cur_time - server_start_time
  client_start_time = sys.tick()
  past_time = interval
  time_update(interval)
end
