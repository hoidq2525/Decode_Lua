local l_waittime_up = 7200
local l_trim_wait_interval = 120
local l_short_wait_time = 1
local l_long_wait_time = 13
local l_last_wait_num = 0
local l_last_wait_time = 0
function on_init(n)
  wait_second = 0
end
function on_confirm()
  wait_second = 0
  ui_startup.relogin_game()
  gx_window.visible = false
end
function reset_time()
  wait_second = 0
end
function on_timer()
  if not gx_window.visible then
    return
  end
  local tm = 0
  if wait_second == 0 then
    l_last_wait_num = ui_queueing.m_numtowait
    tm = ui_queueing.m_numtowait * l_short_wait_time + ui_queueing.m_numtolongwait * l_long_wait_time - wait_second
    l_last_wait_time = tm
  end
  wait_second = wait_second + 1
  if wait_second % l_trim_wait_interval == 0 then
    if l_last_wait_num > 0 then
      reduce_num = l_last_wait_num - ui_queueing.m_numtowait
      if 0 < reduce_num then
        tm = math.floor(l_trim_wait_interval / reduce_num * ui_queueing.m_numtowait)
        l_last_wait_time = tm
      else
        tm = l_last_wait_time - 1
        l_last_wait_time = tm
      end
    end
    l_last_wait_num = ui_queueing.m_numtowait
  else
    tm = l_last_wait_time - 1
    l_last_wait_time = tm
  end
  if tm == 1 and (ui_queueing.m_numtowait > 1 or 0 < ui_queueing.m_numtolongwait) then
    wait_second = 0
  end
  if tm > l_waittime_up then
    tm = l_waittime_up
  end
  local hour = 0
  local minute = 0
  local second = 0
  hour = math.floor(tm / 3600)
  minute = math.floor((tm - hour * 3600) / 60)
  second = tm - hour * 3600 - minute * 60
  if tm < l_waittime_up then
    ui_queueing.m_time.text = ui_widget.merge_mtf({
      h = hour,
      m = minute,
      s = second
    }, ui.get_text("tool|queueing_wait"))
  else
    ui_queueing.m_time.text = ui_widget.merge_mtf({h = hour}, ui.get_text("tool|queueing_wait2"))
  end
end
