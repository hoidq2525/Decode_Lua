g_display_mode = 0
g_display_speed = 0
g_display_tick_count = 0
function on_time_set_bg(timer)
  if sys.check(ui_film.w_main) ~= true then
    timer.suspended = true
    return
  end
  if ui_film.w_main.visible ~= true or g_display_speed == 0 then
    g_film_bg_timer.suspended = true
    return
  end
  execute_display()
end
function execute_display()
  local show_mask
  local dx = ui_film.w_main.dx
  if g_display_mode == 0 or g_display_speed == 0 then
    return
  elseif g_display_mode == 1 then
    bg_rand_mask_left.visible = false
    bg_rand_mask_right.visible = true
    show_mask = bg_rand_mask_right
  elseif g_display_mode == 2 then
    show_mask = bg_rand_mask_left
    bg_rand_mask_left.visible = true
    bg_rand_mask_right.visible = false
  end
  local tick = g_display_tick_count
  local total_tick = g_display_speed
  dx = (1 - tick / total_tick) * dx
  if dx <= 0 then
    dx = 0
  end
  show_mask.dx = dx
  g_display_tick_count = g_display_tick_count + 1
  if tick > total_tick then
    clear_bg_display()
  end
end
function clear_bg_display()
  g_film_bg_timer.suspended = true
  bg_rand_mask_left.visible = false
  bg_rand_mask_right.visible = false
  set_display_mode(0, 0, true)
end
function set_display_mode(display_mode, display_speed, stop)
  g_display_mode = display_mode
  g_display_speed = display_speed * 4
  g_film_bg_timer.suspended = display
  g_display_tick_count = 0
  execute_display()
end
function process_static_picture(pKeyFrameData)
  if sys.check(pKeyFrameData) ~= true then
    return
  end
  local pic_url = pKeyFrameData.param0.v_string
  local pic_count_x = pKeyFrameData.param1.v_int
  local pic_count_y = pKeyFrameData.param2.v_int
  local display_mode = pKeyFrameData.param3.v_int
  local display_speed = pKeyFrameData.param4.v_int
  set_bg_visible(true)
  if display_mode ~= 0 then
    set_display_mode(display_mode, display_speed, false)
  end
  bg_rand:set_range(pic_count_x, pic_count_y)
  local dir = sys.format(L("$image/film/%s"), pic_url)
  local function set_item(x, y, n)
    u = sys.format(L("%s/%d.png"), dir, n)
    bg_rand:set_item(x, y, u)
  end
  local c_max = pic_count_x * pic_count_y - 1
  local c_count = 0
  for j = 0, pic_count_y - 1 do
    for i = 0, pic_count_x - 1 do
      set_item(i, j, c_count)
      c_count = c_count + 1
    end
  end
  local vanish_frame = pKeyFrameData.param5.v_int
  local do_vanish = function()
    g_bg_callback = nil
    set_bg_visible(false)
  end
  g_bg_callback = bo2.AddTimeEvent(vanish_frame, do_vanish)
end
