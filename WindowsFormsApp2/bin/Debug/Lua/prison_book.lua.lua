local PRISON_SCN = 49
local left_time = 0
local total_left_time = 0
function show_book()
  w_main.visible = true
  local v = sys.variant()
  bo2.send_variant(packet.eCTS_UI_GetPrisonData, v)
end
function on_close_click(btn)
  w_main.visible = false
end
function on_show_click(btn)
  if w_main.visible == true then
    w_main.visible = false
  else
    show_book()
  end
  close_flicker()
end
function on_make_show_btn_tip(tip)
  ui_widget.tip_make_view(tip.view, tip.text)
end
function on_show_btn_timer(timer)
  on_show_btn()
end
function on_show_btn()
  local player = bo2.player
  if player ~= nil and sys.check(player) == true then
    local transto_prison_type = player:get_flag_int8(bo2.ePlayerFlagInt8_TransToPrisonType)
    if transto_prison_type == bo2.eTransToPrisonType_Criminal and ui_map.cur_scn_id == PRISON_SCN then
      ui_info_tip.on_click_add_msg(ui_info_tip.info_tip_inc.prison_info)
      local v = sys.variant()
      bo2.send_variant(bo2.eCTS_UI_GetPrisonData, v)
    else
      ui_info_tip.on_click_del_msg(ui_info_tip.info_tip_inc.prison_info)
    end
  end
end
function on_flicker_timer(timer)
  close_flicker()
end
function close_flicker()
  w_show_btn_flicker.visible = false
  w_show_btn_flicker.suspended = true
  w_flicker_timer.suspended = true
end
function on_move(ctrl, pos)
  if ctrl.x + ctrl.dx > 870 then
    ctrl.x = 870 - ctrl.dx
  end
  if ctrl.x < 50 then
    ctrl.x = 50
  end
  if ctrl.y + ctrl.dy > 660 then
    ctrl.y = 660 - ctrl.dy
  end
  if ctrl.y < 30 then
    ctrl.y = 30
  end
end
function on_time_text_timer(timer)
  if left_time > 0 then
    left_time = left_time - 1000
  end
  if total_left_time > 0 then
    total_left_time = total_left_time - 1000
  end
  if left_time <= 0 then
    left_time = 0
  end
  if total_left_time <= 0 then
    total_left_time = 0
  end
  w_main:search("left_time"):search("value_text").text = build_time_text(left_time)
  w_main:search("total_left_time"):search("value_text").text = build_time_text(total_left_time)
end
function on_refresh_book(data)
  local player = bo2.player
  local packet = data:get(packet.key.prison_left_time)
  left_time = packet:get(1).v_int
  total_left_time = packet:get(2).v_int
  left_prison_point = packet:get(3).v_int
  w_main:search("left_time"):search("value_text").text = build_time_text(left_time)
  w_main:search("total_left_time"):search("value_text").text = build_time_text(total_left_time)
  w_main:search("left_prison_point"):search("value_text").text = left_prison_point
  local player_name = bo2.player.name
  w_main:search("owner"):search("value_text").text = player_name
end
function build_time_text(time)
  local left_part = time % 1000
  local time_sec = (time - left_part) / 1000
  local s = math.ceil(time_sec % 60)
  time_sec = (time_sec - s) / 60
  if tonumber(s) < 10 then
    s = "0" .. tostring(s)
  end
  local m = math.ceil(time_sec % 60)
  time_sec = (time_sec - m) / 60
  if tonumber(m) < 10 then
    m = "0" .. tostring(m)
  end
  local h = tonumber(math.ceil(time_sec))
  local text
  if h == 0 then
    text = m .. ":" .. s
  else
    if tonumber(h) < 10 then
      h = "0" .. tostring(h)
    end
    text = h .. ":" .. m .. ":" .. s
  end
  return text
end
