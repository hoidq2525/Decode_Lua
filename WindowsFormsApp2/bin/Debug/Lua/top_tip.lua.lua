g_cur_time = 0
function updata_player_top_tip(data)
  local kill_count = data:get(packet.key.battle_kill_count).v_int
  local dead_count = data:get(packet.key.battle_dead_count).v_int
  str1 = sys.format(ui.get_text("battle|tip_kill_count"), kill_count)
  str2 = sys.format(ui.get_text("battle|tip_dead_count"), dead_count)
  gx_top_tip:search("kill_count").text = str1
  gx_top_tip:search("dead_count").text = str2
end
function top_updata_player(kill_count, dead_count)
  str1 = sys.format(ui.get_text("battle|tip_kill_count"), kill_count)
  str2 = sys.format(ui.get_text("battle|tip_dead_count"), dead_count)
  gx_top_tip:search("kill_count").text = str1
  gx_top_tip:search("dead_count").text = str2
end
function reset_top_tip(data)
  if data.empty then
    return
  end
  str1 = sys.format(ui.get_text("battle|tip_kill_count"), 0)
  str2 = sys.format(ui.get_text("battle|tip_dead_count"), 0)
  gx_top_tip:search("kill_count").text = str1
  gx_top_tip:search("dead_count").text = str2
  gx_top_tip.visible = true
end
function least_number(src_num, n, direction)
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
function on_timer()
  if g_cur_time <= 0 then
    return
  end
  g_cur_time = g_cur_time - 1
  local ONE_MINUTE = 60
  local s = ""
  if ONE_MINUTE >= g_cur_time then
    s = sys.format(ui.get_text("battle|clock_fmt"), least_number(g_cur_time, 2))
  else
    local minute = math.floor(g_cur_time / ONE_MINUTE)
    local second = g_cur_time % ONE_MINUTE
    s = sys.format(ui.get_text("battle|clock_fmt_big"), least_number(minute, 2), least_number(second, 2))
  end
  gx_clock.text = s
end
function set_clock(var)
  g_cur_time = var:get(packet.key.itemdata_val).v_int
  local ONE_MINUTE = 60
  local s = ""
  if ONE_MINUTE >= g_cur_time then
    s = sys.format(ui.get_text("battle|clock_fmt"), least_number(g_cur_time, 2))
  else
    local minute = math.floor(g_cur_time / ONE_MINUTE)
    local second = g_cur_time % ONE_MINUTE
    s = sys.format(ui.get_text("battle|clock_fmt_big"), least_number(minute, 2), least_number(second, 2))
  end
  gx_clock.text = s
  gx_timer.suspended = false
end
